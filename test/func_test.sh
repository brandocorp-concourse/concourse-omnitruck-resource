#!/bin/bash -e
FAILURE='\033[0;31m'
SUCCESS='\033[0;32m'
RESET='\033[0m'

info(){
  echo "$1"
}

log_success(){
  echo -e "\t${GREEN}$1${RESET}"
}

log_failure(){
  echo -e "\t${GREEN}$1${RESET}"
}

validate_output(){
  local rel=$(jq -M -r '.[] | .release' <<< "$1")
  echo $rel
}

test_check_null_version(){
  echo "When no version is requested"
  output=$(/opt/resource/check < /test/fixtures/null.json 2> /dev/null)
  latest=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the latest version ($latest)"
  else
    log_failure "it should not fail"
    exit 1
  fi
}

test_check_latest_version(){
  echo "When the 'latest' version is requested"
  output=$(/opt/resource/check < /test/fixtures/latest.json 2> /dev/null)
  latest=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the latest version ($latest)"
  else
    log_failure "it should not fail"
    exit 1
  fi
}

test_check_requested_version(){
  echo "When a specific version is requested"
  output=$(/opt/resource/check < /test/fixtures/requested.json 2> /dev/null)
  requested=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the requested version ($requested)"
  else
    log_failure "it should not fail"
    exit 1
  fi
}

test_check(){
  echo "Test: /opt/resource/check"
  test_check_null_version
  test_check_latest_version
  test_check_requested_version
}

test_in(){
  true
}

test_out(){
  true
}

main(){
  test_check
  test_in
}

main