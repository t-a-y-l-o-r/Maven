#!/bin/zsh

# TODO: fix this. Possible bug in maven itself prevents capture of user input?
if [[ $# -eq 0 ]] ; then
  echo 'Please provide a process name to search and kill.'
  exit 1
fi

PROCESS_NAME=$1

pgrep -fl "$PROCESS_NAME" | while read -r line ; do
  PID=$(echo $line | cut -d ' ' -f1)
  PROC_NAME=$(echo $line | cut -d ' ' -f2-)

  echo "Found process: $PROC_NAME with PID: $PID"

  read "resp?Do you want to kill this process? (y/n) "

  if [[ "$resp" =~ ^[Yy]$ ]] ; then
    kill -9 $PID
    echo "Killed process $PID"
  else
    echo "Did not kill process $PID"
    break
  fi
done

