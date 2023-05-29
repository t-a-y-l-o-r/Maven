#!/bin/bash

cwd=$(pwd)
escaped_cwd=$(printf '%s\n' "$cwd" | sed -e 's/[\/&]/\\&/g')

sed -i "s|export MAVEN_PROJECT_DIR=.*|export MAVEN_PROJECT_DIR=\"$escaped_cwd\"|g" ~/.config/maven/rc
