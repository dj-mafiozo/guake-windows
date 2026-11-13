"""Compile upstream PO files with GNU gettext; export lossless runtime messages.

No fuzzy or obsolete translations are promoted. Sources and translator credits
remain in locale/po. The runtime builds a vendor/i18n TTranslationCatalog, using
the library itself to produce its legacy text identifiers.
"""
import argparse
import gettext
import json
from pathlib import Path
import struct
import subprocess
import tempfile


def convert(source, msgfmt):
    with tempfile.TemporaryDirectory() as tmp:
        binary = Path(tmp) / 'guake.mo'
        subprocess.run([str(msgfmt), '-o', str(binary), str(source)], check=True)
        data = binary.read_bytes()
        with binary.open('rb') as stream:
            info = gettext.GNUTranslations(stream).info()
    magic = struct.unpack_from('<I', data)[0]
    endian = '<' if magic == 0x950412DE else '>'
    magic, revision, count, originals, translated = struct.unpack_from(endian + '5I', data)
    if magic != 0x950412DE or revision >> 16 > 1:
        raise ValueError(f'Unsupported MO format: {source}')
    entries = []
    for index in range(count):
        length, offset = struct.unpack_from(endian + '2I', data, originals + index * 8)
        original = data[offset:offset + length].decode('utf-8')
        length, offset = struct.unpack_from(endian + '2I', data, translated + index * 8)
        target = data[offset:offset + length].decode('utf-8')
        if not original:
            continue
        variants = original.split('\0')
        context, separator, singular = variants[0].rpartition('\x04')
        if not separator:
            singular = variants[0]
        entries.append(dict(context=context if separator else '', singular=singular,
                            plural=variants[1] if len(variants) > 1 else '',
                            translations=target.split('\0')))
    return dict(language=source.stem.replace('_', '-'),
                pluralRule=info.get('plural-forms', 'nplurals=2; plural=(n != 1);'),
                entries=entries)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--msgfmt', type=Path, default=Path('C:/git-sdk-64/usr/bin/msgfmt.exe'))
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = root / 'Localization' / 'catalogs'
    output.mkdir(parents=True, exist_ok=True)
    for source in sorted((root / 'Localization' / 'po').glob('*.po')):
        catalog = convert(source, args.msgfmt)
        destination = output / (source.stem + '.json')
        destination.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        print(f'{source.stem}: {len(catalog["entries"])}')


if __name__ == '__main__':
    main()