
function _maven() {
  local -a scripts
  scripts=($(find "${HOME}/Git/maven/scripts" -type f -exec basename {} \;))
  scripts=(${scripts[@]%.*})
  _describe 'script' scripts
}

compdef _maven maven
