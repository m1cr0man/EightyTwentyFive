from pathlib import Path
import sys
from argparse import ArgumentParser
from multiprocessing import Pool
from rich import print
from rich_argparse import RichHelpFormatter


def read_dir(path: Path) -> set[str]:
    return {file.name for file in path.rglob("*") if not file.is_dir()}


def main(args: list[str]) -> int:
    parser = ArgumentParser(
        description="Two way recursive diff of file names", formatter_class=RichHelpFormatter
    )

    parser.add_argument("DIRA", help="First directory", type=Path)
    parser.add_argument("DIRB", help="Second directory", type=Path)
    parser.add_argument(
        "--a-only",
        help="Only show first directory diff",
        default=False,
        action="store_true",
    )
    parser.add_argument(
        "--b-only",
        help="Only show second directory diff",
        default=False,
        action="store_true",
    )

    parsed_args = parser.parse_args(args)

    dir_a: Path = parsed_args.DIRA
    dir_b: Path = parsed_args.DIRB

    print("Loading data from directories...")

    with Pool(2) as procpool:
        files_a, files_b = procpool.map(read_dir, [dir_a, dir_b])

    print("Loaded", len(files_a), "files from", dir_a)
    print("Loaded", len(files_b), "files from", dir_b)

    if not parsed_args.b_only:
        print(f"Unique files in {dir_a}")
        for name in files_a.difference(files_b):
            print(name)

    if not parsed_args.a_only:
        print(f"Unique files in {dir_b}")
        for name in files_b.difference(files_a):
            print(name)

    return 0


if __name__ == "__main__":
    main(sys.argv[1:])
