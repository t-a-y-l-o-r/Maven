#!/bin/bash

RESULT=$(sudo docker run --detach --name=redis --publish=6379:6379 redis 2>&1)
EXIT=$?

if [ $EXIT -ne 0 ];
then
  DOCKER_ID=$(echo "$RESULT" | grep -o '".*"' | awk -F '"' '{ print $4 }');
  echo "[*] Docker container already running!"
  echo "[*] Refreshing instance...";

  # check if we need to murder first
  [ "$(sudo docker inspect --format='{{.State.Running}}' ${DOCKER_ID})" = "true" ] &&
    sudo docker kill ${DOCKER_ID} 1>/dev/null

  sudo docker rm ${DOCKER_ID} 1>/dev/null &&
    sudo docker run --detach --name=redis --publish 6379:6379 redis
  exit $?;
fi

echo $RESULT;
exit $EXIT;
