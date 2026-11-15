"""Validate the Delphi IDE project contract without rewriting project files."""
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
NS = {"p": "http://schemas.microsoft.com/developer/msbuild/2003"}
PROJECTS = (
    "Src/guake.dproj",
    "Src/Launchers/git-zsh.dproj",
    "Src/Tests/GuakeTests.dproj",
    "Src/Tests/GuakeFormsPreview.dproj",
)


def validate(project: Path) -> list[str]:
    errors = []
    root = ET.parse(project).getroot()
    imports = root.findall("p:Import", NS)
    standard = [i for i in imports if i.get("Project", "").lower().endswith("codegear.delphi.targets")]
    if len(standard) != 1:
        errors.append("exactly one CodeGear.Delphi.Targets import is required")
    groups = root.findall("p:PropertyGroup", NS)
    markers = {child.tag.split("}")[-1] for g in groups for child in g if child.text == "true"}
    for marker in ("Base", "Base_Win64", "Cfg_1", "Cfg_1_Win64", "Cfg_2", "Cfg_2_Win64"):
        if marker not in markers:
            errors.append(f"missing IDE configuration marker {marker}")
    base = next((g for g in groups if g.get("Condition") == "'$(Base)'!=''"), None)
    if base is None:
        errors.append("missing common Base options")
        return errors
    values = {c.tag.split("}")[-1]: c.text or "" for c in base}
    for key in ("DCC_UnitSearchPath", "DCC_ExeOutput", "DCC_DcuOutput", "DCC_MapFile",
                "Manifest_File", "Icon_MainIcon", "VerInfo_Build", "VerInfo_Release"):
        if not values.get(key):
            errors.append(f"missing common option {key}")
    for event, script in (("PreBuildEvent", "Prepare-Build.ps1"), ("PostBuildEvent", "Complete-Build.ps1")):
        if script not in values.get(event, "") or "$(DCC_ExeOutput)" not in values.get(event, ""):
            errors.append(f"{event} must use {script} and the shared DCC_ExeOutput property")
    for key in ("VerInfo_MajorVer", "VerInfo_MinorVer", "VerInfo_Release", "VerInfo_Build", "VerInfo_Keys"):
        if len(root.findall(f".//p:{key}", NS)) != 1:
            errors.append(f"{key} must occur only in common Base options")
    if any("BeforeTargets" in e.attrib or "AfterTargets" in e.attrib for e in root.iter()):
        errors.append("old Delphi project parser does not support BeforeTargets/AfterTargets")
    main = root.find("p:PropertyGroup/p:MainSource", NS)
    if main is None:
        errors.append("missing MainSource")
        return errors
    source = project.parent / main.text
    text = source.read_text(encoding="utf-8-sig")
    if not re.search(r"\buses\s+StackTrace\s+in\b", text, re.I):
        errors.append("StackTrace must remain first in DPR uses")
    declared = {
        (project.parent / path.replace("\\", "/")).resolve()
        for path in re.findall(r"\b[\w.]+\s+in\s+'([^']+\.pas)'", text, re.I)
    }
    referenced = {
        (project.parent / item.get("Include").replace("\\", "/")).resolve()
        for item in root.findall("p:ItemGroup/p:DCCReference", NS)
        if item.get("Include", "").lower().endswith(".pas")
    }
    for path in sorted(declared - referenced):
        errors.append(f"DPR unit missing from DCCReference: {path.name}")
    for path in sorted(referenced - declared):
        errors.append(f"DCCReference missing from DPR: {path.name}")
    for path in declared | referenced:
        if not path.is_file():
            errors.append(f"missing source: {path}")
    return errors


def main() -> int:
    failed = False
    for relative in PROJECTS:
        errors = validate(ROOT / relative)
        if errors:
            failed = True
            for error in errors:
                print(f"{relative}: {error}", file=sys.stderr)
        else:
            print(f"{relative}: OK")
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
