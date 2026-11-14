"""Generate matching PDB symbols from the detailed Delphi MAP."""
import argparse
import hashlib
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('map', type=Path)
    parser.add_argument('--map2pdb', default='map2pdb.exe')
    args = parser.parse_args()
    executable = args.map.with_suffix('.exe')
    before = hashlib.sha256(executable.read_bytes()).digest()
    subprocess.run([args.map2pdb, '-include:0001;0002', str(args.map)], check=True)
    pdb = args.map.with_suffix('.pdb')
    if not pdb.is_file() or pdb.stat().st_size == 0:
        raise RuntimeError(f'Missing PDB: {pdb}')
    if hashlib.sha256(executable.read_bytes()).digest() != before:
        raise RuntimeError(f'Symbol generation modified the executable: {executable}')


if __name__ == '__main__':
    main()
