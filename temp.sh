#!/bin/bash

# activate conda
export ANACONDA_ROOT='/c/anaconda3'
. "${ANACONDA_ROOT}/etc/profile.d"/conda.sh

export GitRepoRoot="https://github.com/rdarie/"
export GitFolder="${HOME}/Documents/GitHub"
export ENV_DIR="${ANACONDA_ROOT}/envs/isi_env"

conda activate
conda activate isi_env

echo "python version: "$(python --version)
echo PYTHONPATH=$PYTHONPATH

for FILE in ./external_wheels/windows/*.whl; do
    echo "Installing ${FILE}"
    python -m pip install "${FILE}" --no-build-isolation --upgrade --no-cache-dir
done

RepoList=(\
"pyqtgraph" \
"ephyviewer" \
"ISI_Vicon_DataStream_MOCK" \
"pyacq" \
)

RepoOptsList=(\
"" \
" -b rippleViewerV2" \
"" \
"" \
)

cloneRepos=false

if [[ $cloneRepos = true ]]
then
    # make directory for cloned repos
    CUSTOMDIR="${HOME}/ripple_viewer_repos"
    rm -rf $CUSTOMDIR
    mkdir $CUSTOMDIR
    cd $CUSTOMDIR
    # clone and install other repos
    for i in ${!RepoList[@]}; do
        echo $i
        # clone the repo
        repoOpts=${RepoOptsList[i]}
        echo "repoOpts =${repoOpts}"
        repoName=${RepoList[i]}
        echo "repoName =${repoName}"
        #
        echo "Cloning ${GitRepoRoot}${repoName}.git${repoOpts}"
        eval "git clone ${GitRepoRoot}${repoName}.git${repoOpts}"
        #
        echo "Installing "$GitRepoRoot$repoName
        # enter this repo
        cd $repoName
        # pwd
        python setup.py develop --install-dir=$PYTHONPATH --no-deps
        cd $CUSTOMDIR
    done
else
    # Install other repos
    for i in ${!RepoList[@]}; do
        repoName=${RepoList[i]}
        echo "Installing: ${GitFolder}/${repoName}"
        cd "${GitFolder}/${repoName}"
        python setup.py develop --no-deps --install-dir=$PYTHONPATH
        cd "${GitFolder}"
    done
fi

# viconSDKPath="/c/Program Files/Vicon/DataStream SDK/Win64/Python/vicon_dssdk"
# cd "${viconSDKPath}"
# python setup.py develop --install-dir=$PYTHONPATH --no-deps

cd "${GitFolder}/rippleViewer"
python setup.py develop --install-dir=$PYTHONPATH --no-deps

echo "python version: "$(python --version)
conda list --explicit > ./conda-spec-file-win.txt
pip freeze > ./pip-spec-file-win.txt
conda env export > ./full-environment-win.yml
conda env export --from-history > ./short-environment-win.yml
