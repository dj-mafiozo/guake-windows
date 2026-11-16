"""Copy an executable's first icon group without executing or changing the EXE."""
import argparse
import hashlib
import json
from pathlib import Path
import struct


def extract_icon(path):
    data = Path(path).read_bytes()
    pe = struct.unpack_from('<I', data, 0x3c)[0]
    if data[pe:pe + 4] != b'PE\0\0':
        raise ValueError('Not a PE executable')
    count = struct.unpack_from('<H', data, pe + 6)[0]
    optional_size = struct.unpack_from('<H', data, pe + 20)[0]
    optional = pe + 24
    magic = struct.unpack_from('<H', data, optional)[0]
    directory = optional + {0x10b: 96, 0x20b: 112}[magic]
    resource_rva = struct.unpack_from('<I', data, directory + 16)[0]
    sections = optional + optional_size

    def offset(rva):
        for i in range(count):
            size, address, raw_size, raw = struct.unpack_from('<IIII', data, sections + 40 * i + 8)
            if address <= rva < address + max(size, raw_size):
                return raw + rva - address
        raise ValueError('Resource RVA outside PE sections')

    base = offset(resource_rva)

    def entries(relative):
        named, ids = struct.unpack_from('<HH', data, base + relative + 12)
        return [struct.unpack_from('<II', data, base + relative + 16 + 8 * i)
                for i in range(named + ids)]

    types = dict(entries(0))

    def first_blob(node):
        if node & 0x80000000:
            return first_blob(entries(node & 0x7fffffff)[0][1])
        rva, size = struct.unpack_from('<II', data, base + node)
        start = offset(rva)
        blob = data[start:start + size]
        if len(blob) != size:
            raise ValueError('Truncated icon resource')
        return blob

    group = first_blob(types[14])
    reserved, kind, images = struct.unpack_from('<HHH', group)
    if reserved != 0 or kind != 1 or not images:
        raise ValueError('Invalid icon group')
    icons = dict(entries(types[3] & 0x7fffffff))
    header = bytearray(struct.pack('<HHH', 0, 1, images))
    payload = bytearray()
    for i in range(images):
        width, height, colors, zero, planes, bits, size, resource_id = struct.unpack_from('<BBBBHHIH', group, 6 + 14 * i)
        blob = first_blob(icons[resource_id])
        if size != len(blob):
            raise ValueError('Icon size differs from group descriptor')
        header.extend(struct.pack('<BBBBHHII', width, height, colors, zero, planes, bits,
                                  size, 6 + 16 * images + len(payload)))
        payload.extend(blob)
    return bytes(header + payload)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=Path('C:/git-sdk-64/usr/bin/zsh.exe'))
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'Resources/zsh.ico')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    icon = extract_icon(args.source)
    if args.check:
        if args.output.read_bytes() != icon:
            raise SystemExit('Executable icon does not match ' + str(args.output))
        print('Icon matches:', args.source)
        return
    args.output.write_bytes(icon)
    args.output.with_suffix('.source.json').write_text(json.dumps({
        'source': str(args.source),
        'source_sha256': hashlib.sha256(args.source.read_bytes()).hexdigest(),
        'icon_sha256': hashlib.sha256(icon).hexdigest(),
    }, indent=2) + '\n', encoding='utf-8')
    print(args.output)


if __name__ == '__main__':
    main()
