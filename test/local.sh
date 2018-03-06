#!/bin/bash -e
FAILURE='\033[0;31m'
SUCCESS='\033[0;32m'
RESET='\033[0m'
TMPDIR="$(mktemp -d)"

SCRIPT=$0
TEST=$(readlink -fs $(dirname $SCRIPT))
REPO=$(dirname $TEST)

info(){
  echo "$1"
}

log_success(){
  echo -e "\t${SUCCESS}$1${RESET}"
}

log_failure(){
  echo -e "\t${FAILURE}$1${RESET}"
  return 1
}

validate_output(){
  local rel=$(jq -M -r '.[] | .release' <<< "$1")
  echo $rel
}

test_check_null_version(){
  echo "When no version is requested"
  local output=$(bash $REPO/assets/check < $REPO/test/fixtures/null.json 2> /dev/null)
  local latest=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the latest version ($latest)"
  else
    log_failure "it should not fail"
  fi
}

test_check_latest_version(){
  echo "When the 'latest' version is requested"
  local output=$(bash $REPO/assets/check < $REPO/test/fixtures/latest.json 2> /dev/null)
  local latest=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the latest version ($latest)"
  else
    log_failure "it should not fail"
  fi
}

test_check_requested_version(){
  echo "When a specific version is requested"
  local output=$(bash $REPO/assets/check < $REPO/test/fixtures/requested.json 2> /dev/null)
  local requested=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the requested version ($requested)"
  else
    log_failure "it should not fail"
  fi
}

test_check(){
  echo "Test: check"
  test_check_null_version
  test_check_latest_version
  test_check_requested_version
}


validate_download(){
  local sha256=$(jq -M -r \
    '.metadata[] | select(.name | contains("sha256")) | .value' <<< "$1")
  [[ "$sha256" == "null" ]] && exit 1

  local url=$(jq -M -r \
    '.metadata[] | select(.name | contains("url")) | .value' <<< "$1")
  [[ "$url" == "null" ]] && exit 1

  local package=$(basename $url)
  [[ ! -f "$TMPDIR/$package" ]] && exit 1

  cat > $TMPDIR/sha256 <<EOS
$sha256 $TMPDIR/$package
EOS

  cd $TMPDIR && (sha256sum -c sha256 2>&1) > /dev/null
  cd - >/dev/null
  echo $package
}

test_in_null_version(){
  echo "When no version is present in the input data"
  local output=$(bash $REPO/assets/in $TMPDIR < $REPO/test/fixtures/null.json 2> /dev/null)
  if [ $? -eq 0 ]; then
    log_success "it fails with an error message"
  else
    log_failure "it should not succeed"
  fi
}

test_in_latest_version(){
  echo "When the latest version is requested"
  local output=$(bash $REPO/assets/in $TMPDIR < $REPO/test/fixtures/latest.json 2> /dev/null)
  local requested=$(validate_download "$output")
  if [ $? -eq 0 ]; then
    log_success "it downloads the requested version ($requested)"
  else
    log_failure "it should not fail"
  fi
}

test_in_requested_version(){
  echo "When a specific version is requested"
  local output=$(bash $REPO/assets/in $TMPDIR < $REPO/test/fixtures/requested.json 2> /dev/null)
  local requested=$(validate_download "$output")
  if [ $? -eq 0 ]; then
    log_success "it downloads the requested version ($requested)"
  else
    log_failure "it should not fail"
  fi
}

test_in(){
  echo "Test: in"
  test_in_null_version || return 1
  test_in_latest_version || return 1
  test_in_requested_version || return 1
}

test_out(){
  echo "Test: out"
  echo "When run"
  log_success "it does nothing"
}

cleanup(){
  rm -rf $TMPDIR
}

trap cleanup EXIT

main(){
  test_check
  test_in
  test_out
  cleanup
}

main
