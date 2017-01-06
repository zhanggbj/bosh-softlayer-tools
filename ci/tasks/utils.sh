#!/usr/bin/env bash
check_param() {
  local name=$1
  local value=$(eval echo '$'$name)
  if [ "$value" == 'replace-me' ]; then
    echo "environment variable $name must be set"
    exit 1
  fi
}

declare -a on_exit_items
on_exit_items=()

function on_exit {
  echo "Running ${#on_exit_items[@]} on_exit items..."
  for i in "${on_exit_items[@]}"
  do
    for try in $(seq 0 9); do
      sleep $try
      echo "Running cleanup command $i (try: ${try})"
        eval $i || continue
      break
    done
  done
}

function add_on_exit {
  local n=${#on_exit_items[@]}
  if [[ $n -eq 0 ]]; then
    on_exit_items=("$*")
    trap on_exit EXIT
  else
    on_exit_items=("$*" "${on_exit_items[@]}")
  fi
}

function print_title (){
  divider="==========================================================================="
  echo ${divider}
  echo $1
  echo ${divider}
}

func install_bosh_cli (){
  print_title "INSTALL BOSH CLI..."
  gem install bosh_cli --no-ri --no-rdo c

  echo "using bosh CLI version..."
  bosh version

  export BOSH_CLIENT=fake_client
  export BOSH_CLIENT_SECRET=fake_secret
}
