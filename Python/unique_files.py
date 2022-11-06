from pathlib import Path
import shutil
import sys
from argparse import ArgumentParser
from multiprocessing import Pool
from typing import Optional
from rich import print
from rich_argparse import RichHelpFormatter


def read_dir(path: Path) -> set[Path]:
    return {file for file in path.rglob("*") if not file.is_dir()}


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
    parser.add_argument(
        "--copy-missing-to",
        help="Where to copy unique files to",
        type=Path,
        default=None,
    )
    parser.add_argument(
        "--delete-missing",
        help="Delete missing/mismatched files (happens after copy if specified)",
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

    dict_a = {f.name: f for f in files_a}
    dict_b = {f.name: f for f in files_b}
    set_a = set(dict_a.keys())
    set_b = set(dict_b.keys())

    dest: Optional[Path] = parsed_args.copy_missing_to

    if dest and not dest.exists():
        print(f"Creating '{dest}'")
        dest.mkdir()

    if not parsed_args.b_only:
        print(f"Unique files in '{dir_a}'")
        for name in set_a.difference(set_b):
            print(name)
            if dest:
                shutil.copy2(str(dict_a[name]), dest)
            if parsed_args.delete_missing:
                print(f"Deleting '{dict_a[name]}'")
                dict_a[name].unlink()

    if not parsed_args.a_only:
        print(f"Unique files in '{dir_b}'")
        for name in set_b.difference(set_a):
            print(name)
            if dest:
                shutil.copy2(str(dict_b[name]), dest)
            if parsed_args.delete_missing:
                print(f"Deleting '{dict_b[name]}'")
                dict_b[name].unlink()

    return 0


if __name__ == "__main__":
    main(sys.argv[1:])
