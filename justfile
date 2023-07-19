# Set shell for Windows OSs (PowerShell Core):
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]
set dotenv-load := false

# OS-specific Python nomenclature
bool_prefix := if os_family() == "windows" { "$" } else { "" }
python_dir := if os_family() == "windows" { ".venv/Scripts" } else { ".venv/bin" }
python := python_dir + if os_family() == "windows" { "/python.exe" } else { "/python" }
system_python := if os_family() == "windows" { "py.exe" } else { "python" }

# Repository information
repo_user := "tataraba"
repo_name := "pyhat-fastapi"
repo := "https://github.com/" + repo_user + "/" + repo_name + ".git"
repo_dir := invocation_directory() + "/" + repo_name

venv_exists := bool_prefix + path_exists(repo_dir + "/.venv")


@_default:
    just --list

@_fmt:
    just --fmt --unstable


# Create a new PyHAT project in the current directory
@pyhat:
    echo "Building PyHAT project into {{repo_name}} directory"
    just setup
    cd {{ repo_name }} && {{ python_dir }}/uvicorn app.main:app --reload

# Clone PyHAT-fastapi repo and install dependencies
@setup:
    echo "Setting up your project"
    echo "Cloning {{ repo }}"
    git clone {{ repo }}
    just dependencies
    just tw


# Install dependencies using pdm
@dependencies:
    # cd repo_dir && pdm install || just _venv_then_pdm
    echo "Installing dependencies..."
    cd {{ repo_name }} && just _venv_then_pdm


# Create virtual environment, install pdm, and use pdm to install deps
@_venv_then_pdm:
    just create_venv
    {{ repo_name }}/{{ python }} -m pip install pdm
    "Installing dependencies with PDM"
    cd {{ repo_name }} && {{ python_dir }}/pdm install

# Create virtual environment
@create_venv:
    echo "Attempting to create virtual environment..."
    if (-not {{ venv_exists }}) { just _venv } else { echo "Virtual environment already exists"}

# Initiate (download) tailwindcss cli
@tw:
    cd {{ repo_name }} && {{ python_dir }}/tailwindcss_install
    cd {{ repo_name }} && {{ python_dir}}/tailwindcss init
    just tw_watch

# Compile tailwind and start a watcher for file changes
@tw_watch:
    cd {{ repo_name }} && {{ python_dir }}/tailwindcss -i ./app/static/src/tw.css -o ./app/static/css/main.css --watch


# Command for creating
@_venv:
    {{ system_python }} -m venv {{ repo_name}}/.venv --upgrade-deps


@_test:
    cd {{ repo_name }} && {{ python_dir }}/uvicorn app.main:app --reload