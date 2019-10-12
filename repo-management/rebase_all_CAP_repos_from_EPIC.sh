DEFAULT_ORIGIN_FORK="change-the-origin";
ORIGIN_FORK=${DEFAULT_ORIGIN_FORK};
LOCAL_PROJECT_BASE_PATH=~/git/; #unquoted for tilde expansion

if [ ! -z "${1}" ]; then ORIGIN_FORK=$1; fi
if [ ! -z "${2}" ]; then LOCAL_PROJECT_BASE_PATH=$2; fi

updateFork(){
    local _your_origin_fork=$1;
    local _local_project_base_path=$2;
    local _repo=$3;
    local _base_branch=$4;
    if [ -z "${_your_origin_fork}" ]; then
        echo -e \\n"An origin fork belonging to you must be provided."\\n;
        exit 1;
    fi
    if echo "${_your_origin_fork}" | grep "${DEFAULT_ORIGIN_FORK}"; then
        echo;
        echo "USAGE: ./rebase_all_CAP_repos_from_EPIC.sh [Your case-sensitive GitHub user name] [local machine basepath to your local projects]";
        echo " eg.";
        echo "./rebase_all_CAP_repos_from_EPIC.sh BillyGithub ~/git/";
        echo;
        exit 1;
    fi
    if [ -z "${_local_project_base_path}" ]; then
        echo -e \\n"A local project base path must be provided.  This is the parent folder in which you store all your repos.  Eg. ~/git/"\\n;
        exit 1;
    fi
    
    if ! echo "${_local_project_base_path}" | grep "\/$"; then
        echo -e \\n"Local project base path '${_local_project_base_path}' must have a trailing slash because it will be used to assemble other paths.  Eg. ~/git/"\\n;
        exit 1;
    fi
    if [ -z "${_repo}" ]; then
        echo -e \\n"A repo name must be provided."\\n;
        exit 1;
    fi
    if [ -z "${_base_branch}" ]; then
        echo -e \\n"A base branch that the repo uses must be provided.  In most cases this is 'master' or 'develop' but may vary depending on the github repo settings."\\n;
        exit 1;
    fi

    local _launch_path=$(pwd);
    local _full_repo_path=${_local_project_base_path}cap-${_repo};
    
    cd ${_full_repo_path};
    
    if ! git status | grep 'nothing to commit, working directory clean\|nothing to commit, working tree clean'; then
        echo -e \\n"You appear to have uncommitted changes in repo '${_full_repo_path}'. Exiting to allow you to deal with it."\\n;
        cd ${_launch_path};
        exit 1;
    fi
    if ! git remote -v | grep "${_your_origin_fork}"; then
        echo -e \\n"You appear to have your origin set incorrectly as your fork '${_your_origin_fork}' is not listed in the git remotes.  Could you accidentally be pointing directly at a repo in the 'bcgov' github org?  Exiting to allow you to correct your remote origin."\\n;
        cd ${_launch_path};
        exit 1;
    fi

    git remote rm upstream;
    git remote add upstream "https://github.com/bcgov/cap-${_repo}.git";
    git fetch upstream;
    git rebase "upstream/${_base_branch}";
    # git push -u origin "${_base_branch}";
    git remote rm upstream;
    git remote add upstream "https://github.com/bcgov/${_repo}.git";
    git fetch upstream;
    git rebase "upstream/${_base_branch}";
    # git push -u origin "${_base_branch}";
    git remote rm upstream;
    git remote add upstream "https://github.com/bcgov/cap-${_repo}.git";

    cd ${_launch_path};
}

updateFork ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-api" "develop";
updateFork ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-admin" "develop";
updateFork ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-public" "develop";
updateFork ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-dev-guides" "master";
updateFork ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-helper-pods" "master";
