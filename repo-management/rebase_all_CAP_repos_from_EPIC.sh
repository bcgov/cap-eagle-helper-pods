DEFAULT_ORIGIN_FORK="change-the-origin";
ORIGIN_FORK=${DEFAULT_ORIGIN_FORK};
LOCAL_PROJECT_BASE_PATH=~/git/; #unquoted for tilde expansion
TEST_ONLY_UPSTREAM_TARGET="test-only";
CAP_UPSTREAM_TARGET="cap";
EPIC_UPSTREAM_TARGET="epic";

if [ ! -z "${1}" ]; then ORIGIN_FORK=$1; fi
if [ ! -z "${2}" ]; then LOCAL_PROJECT_BASE_PATH=$2; fi

updateFork(){
    local _upstream_target=$1;
    local _your_origin_fork=$2;
    local _local_project_base_path=$3;
    local _repo=$4;
    local _base_branch=$5;
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

    if [ ! -d "${_full_repo_path}" ]; then
      echo -e \\n"You appear to have not cloned '${_full_repo_path}'. Exiting to allow you to deal with it."\\n;
      exit 1;
    fi

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
    case $_upstream_target in
     ${CAP_UPSTREAM_TARGET})
          echo "Starting rebase from upstream bcgov/cap-${_repo} onto local/${_repo}";
          git remote rm upstream;
          git remote add upstream "https://github.com/bcgov/cap-${_repo}.git";
          git fetch upstream;
          git rebase "upstream/${_base_branch}";
          # git push -u origin "${_base_branch}";
          echo "Completed rebase from upstream bcgov/cap-${_repo} onto local/${_repo}";
          ;;
     ${EPIC_UPSTREAM_TARGET})
          echo "Starting rebase from upstream bcgov/${_repo} onto local/${_repo}";
          git remote rm upstream;
          git remote add upstream "https://github.com/bcgov/${_repo}.git";
          git fetch upstream;
          git rebase "upstream/${_base_branch}";
          # git push -u origin "${_base_branch}";
          git remote rm upstream;
          git remote add upstream "https://github.com/bcgov/cap-${_repo}.git";
          echo "Completed rebase from upstream bcgov/${_repo} onto local/${_repo}";
          ;;
     ${TEST_ONLY_UPSTREAM_TARGET}|*)
          echo "Completed checking local/cap-${_repo}";
          cd ${_launch_path};
          return;
          ;;
    esac
    cd ${_launch_path};
}

processRepos(){
  local _upstream_target=$1;
  updateFork ${_upstream_target} ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-api" "develop";
  updateFork ${_upstream_target} ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-admin" "develop";
  updateFork ${_upstream_target} ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-public" "develop";
  updateFork ${_upstream_target} ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-dev-guides" "master";
  updateFork ${_upstream_target} ${ORIGIN_FORK} ${LOCAL_PROJECT_BASE_PATH} "eagle-helper-pods" "master";
}

# Test for any local uncommitted work and stop on failure first so that the 
# user has the opportunity to correct before any changes are applied.
processRepos ${TEST_ONLY_UPSTREAM_TARGET};

# Check for other CAP team work on the CAP repos
processRepos ${CAP_UPSTREAM_TARGET};
# If there are changes that came down in the previous step from other CAP 
# team members, the next test step will catch them and give the opportunity
# to review and push.
processRepos ${TEST_ONLY_UPSTREAM_TARGET};

TIMESTAMP_NOW=$(date "+%Y%m%d%H%M%S");
git branch "rebase-${TIMESTAMP_NOW}";
git checkout "rebase-${TIMESTAMP_NOW}";

# Check for new EPIC changes on the EPIC repos
processRepos ${EPIC_UPSTREAM_TARGET};
# Let the user know which repos have changes to look at and push up
processRepos ${TEST_ONLY_UPSTREAM_TARGET};

git commit -a -m "Rebasing cap-eagle repos from latest eagle repos ${TIMESTAMP_NOW}";

# Manually review and push changes to origin here, which can then be PR'd to
# the CAP repo upstream.
