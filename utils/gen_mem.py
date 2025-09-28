#!/usr/bin/env python3
import sys
from typing import List, Iterable

def parse_lines_from_text(text: str) -> List[str]:
    """
    Devuelve una lista de tokens hex sin prefijo 0x en el orden
    en que aparecen en el texto, eliminando comentarios (#...) y líneas vacías.
    """
    tokens = []
    for raw in text.splitlines():
        line = raw.split('#', 1)[0].strip()
        if not line:
            continue
        line = line.lower()
        if line.startswith('0x'):
            line = line[2:]
        tokens.append(line)

    return tokens

def split_to_16bit_words(hexstr: str) -> List[str]:
    """
    Dado un string hex (sin 0x, par de dígitos), devuelve lista de palabras
    de 16 bits en notación little-endian (cada palabra 4 hex dígitos, 'XXXX').
    """
    chunks = []
    for i in range(len(hexstr), 0, -4):
        chunk = hexstr[i-4:i]
        chunks.append(f"0x{chunk}")
    return chunks

def process_input(text: str) -> List[str]:
    tokens = parse_lines_from_text(text)
    out_words = []
    for t in tokens:
        words = split_to_16bit_words(t)
        out_words.extend(words)
    return out_words

def main(argv: List[str]):
    if len(argv) < 3:
        print("Usage: %s <input_code_n_data.mem> <output_code_n_data.mem>" % (argv[0]))
        sys.exit(1)

    input_path = argv[1]
    with open(input_path, 'r', encoding='utf-8') as f:
        text = f.read()

    words = process_input(text)
    processed = '\n'.join(words) + '\n'

    print(processed)

    output_path = argv[2]
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(processed)

if __name__ == "__main__":
    main(sys.argv)
