import re
import subprocess

def read_sources_list(filepath):
    with open(filepath, 'r') as file:
        lines = file.readlines()
    return lines

def replace_subdomains(lines):
    updated_lines = []
    for line in lines:
        updated_line = re.sub(r'(\w+)\.([\w.-]+\.\w+)', r'ir.\2', line)
        updated_lines.append(updated_line)
    return updated_lines

def write_sources_list(filepath, lines):
    with open(filepath, 'w') as file:
        file.writelines(lines)

def update_apt():
    subprocess.run(['sudo', 'apt', 'update'], check=True)

def main():
    filepath = '/etc/apt/sources.list'    
    lines = read_sources_list(filepath)
    
    updated_lines = replace_subdomains(lines)
    
    write_sources_list(filepath, updated_lines)
    
    update_apt()

if __name__ == "__main__":
    main()
