import subprocess
import sys
import platform
import pathlib
import os
import argparse

has_chardet = True
try:
    import chardet
except ImportError:
    has_chardet = False


parent_dir = pathlib.Path(__file__).parent.resolve()

base_configuration_options = "no-comp no-idea no-weak-ssl-ciphers"
windows_configuration_options = f'{base_configuration_options} ASFLAGS=""'

parser = argparse.ArgumentParser(
    description="A script that runs in different modes.")

# Define the --is_test flag
parser.add_argument("--is_test", default=False,
                    help="Run the script in test mode.")

# Parse the arguments
args = parser.parse_args()


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def detect_encoding(file_path):
    encoding = ""
    with open(file_path, "rb") as file:
        raw_data = file.read()
        result = chardet.detect(raw_data)
        encoding = result["encoding"]
    return encoding


def replace_string_in_files(files_to_replace_in, old_string, new_string):
    for file_name in files_to_replace_in:

        file_path = os.path.join(parent_dir, file_name)

        eprint(f"Replacing {old_string} with {new_string} in {file_path}")

        encoding = "utf-8"
        if has_chardet:
            encoding = detect_encoding(file_path)

        eprint(f"Has encoding {encoding}")

        # Read the file content
        with open(file_path, "r", encoding=encoding) as file:
            content = file.read()

        # Replace the old string with the new string
        modified_content = content.replace(old_string, new_string)

        # Write the modified content back to the file
        with open(file_path, "w", encoding=encoding) as file:
            file.write(modified_content)

        eprint("Finished replacing content")


def run_configure_and_make(
    configure_options, external_file_path, make_func_command, test_make_func_command
):
    os.chdir(parent_dir)

    replace_string_in_files(
        ["Configure", "util/dofile.pl", "test/generate_ssl_tests.pl"],
        "external/perl/MODULES.txt",
        f"external/{external_file_path}/perl/MODULES.txt",
    )
    replace_string_in_files(
        ["Configure"],
        'die "[*]\\{5\\} Unsupported options:',
        "***** Unsupported options:#",
    )
    replace_string_in_files(
        ["configdata.pm.in"],
        "'external', 'perl', 'MODULES.txt'",
        f"'external', '{external_file_path}', 'perl', 'MODULES.txt'",
    )

    # On Windows the symlink for this data is broken so we point
    # the perl script to the location of the actual files.
    if platform.system() == "Windows":
        dir = "test/recipes/91-test_pkey_check_data"
        symlink_dir = os.path.join(parent_dir, dir)

        just_real_parent_dir = ""
        for file in os.listdir(symlink_dir):
            symlink = os.path.join(symlink_dir, file)
            real_path = pathlib.Path(os.path.realpath(symlink))

            just_real_parent_dir = real_path.parent.absolute()
            break

        replace_string_in_files(
            ["test/recipes/91-test_pkey_check.t"],
            "$f = data_file($f);",
            f"$f = '{just_real_parent_dir}\\\\' . $f;",
        )

    configure_path = os.path.join(parent_dir, "Configure")
    eprint(f"Running {configure_path}")

    config_process = None
    if platform.system() == "Darwin" or platform.system() == "Windows":
        config_process = subprocess.Popen(
            ["Perl", configure_path] + configure_options.split(), cwd=parent_dir
        )
    else:
        config_process = subprocess.Popen(
            [configure_path] + configure_options.split(), cwd=parent_dir
        )

    config_process.wait()
    eprint("Finished running Configure")
    make_func_process = None
    if args.is_test:
        make_func_process = subprocess.Popen(
            test_make_func_command, cwd=parent_dir)
    else:
        make_func_process = subprocess.Popen(make_func_command, cwd=parent_dir)

    make_func_process.wait()


eprint(parent_dir)

if platform.system() == "Windows":
    run_configure_and_make(
        windows_configuration_options, "external~override", [
            "nmake"], ["nmake", "test"]
    )
else:
    run_configure_and_make(
        base_configuration_options,
        "external~",
        ["make"],
        ["make", "test"],
    )
