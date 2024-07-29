import argparse
import chardet
import os
import fileinput
import pathlib
import platform
import subprocess
import sys


parent_dir = pathlib.Path(__file__).parent.resolve()


parser = argparse.ArgumentParser(description="A script that runs in different modes.")

# Define the --is_test flag
parser.add_argument('--is_test', default=False, help='Run the script in test mode.')

# Parse the arguments
args = parser.parse_args()

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def detect_encoding(file_path):
    encoding = ''
    with open(file_path, 'rb') as file:
        raw_data = file.read()
        result = chardet.detect(raw_data)
        encoding = result['encoding']
    return encoding

def replace_string_in_files(files_to_replace_in, old_string, new_string):
    for file_name in files_to_replace_in:

        file_path = os.path.join(parent_dir, file_name)

        eprint(f'Replacing {old_string} with {new_string} in {file_path}')

        encoding = detect_encoding(file_path)

        eprint(f'Has encoding {encoding}')

        # Read the file content
        with open(file_path, 'r', encoding=encoding) as file:
            content = file.read()
        
        # Replace the old string with the new string
        modified_content = content.replace(old_string, new_string)
        
        # Write the modified content back to the file
        with open(file_path, 'w', encoding=encoding) as file:
            file.write(modified_content)

        eprint('Finished replacing content')



if platform.system() == "Windows": 
    replace_string_in_files(["Configure","util/dofile.pl", "test/generate_ssl_tests.pl"], "external/perl/MODULES.txt", "external/external~override/perl/MODULES.txt")
    replace_string_in_files(["Configure"], "die \"[*]\\{5\\} Unsupported options:", "***** Unsupported options:#")
    replace_string_in_files(["configdata.pm.in"], "'external', 'perl', 'MODULES.txt'", "'external', 'external~override', 'perl', 'MODULES.txt'")
else: 
    replace_string_in_files(["Configure","util/dofile.pl", "test/generate_ssl_tests.pl"], "external/perl/MODULES.txt", "external/external~/perl/MODULES.txt")
    replace_string_in_files(["Configure"], "die \"[*]\\{5\\} Unsupported options:", "***** Unsupported options:#")
    replace_string_in_files(["configdata.pm.in"], "'external', 'perl', 'MODULES.txt'", "'external', 'external~', 'perl', 'MODULES.txt'")



eprint("Running Configure")
configure_path = os.path.join(parent_dir, "Configure")
os.system(f"Perl {configure_path}")
eprint("Finished running Configure")

if platform.system() == "Windows":
    if args.is_test:
        os.system(f"cd {parent_dir} && nmake test")
    else:
        os.system(f"cd {parent_dir} && nmake")
else:    
    if args.is_test:
        os.system(f"cd {parent_dir} && make test")
    else:
        os.system(f"cd  {parent_dir} && make")
