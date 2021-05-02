#!/bin/bash

set -Eeuo pipefail


resolve_full_path() {
    # Why doesn't bash have an easy way to do this?
    python -c "from pathlib import Path; print(Path('$1').resolve())"
}


local_directory=$1
src_dir=$(resolve_full_path $2)

output_archive=$(resolve_full_path $3)

tmp_dir=$(mktemp -d)
tmp_requirements_file=$(mktemp)

python -m pip install pipenv

pushd $local_directory

# Editable and target do not work well together and the private repo needs to be set editable in the Pipfile.
# See the github issue here and those referenced:
#   https://github.com/pypa/pip/issues/4390
pipenv lock -r | sed 's/-e //g' > $tmp_requirements_file

cp -R $src_dir/* $tmp_dir/
pip install -r $tmp_requirements_file -t $tmp_dir

pushd $tmp_dir
zip -r $output_archive .

