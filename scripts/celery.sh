#!/bin/bash

PROJECT=${MAVEN_PROJECT_DIR##*/}
poetry run celery -A ${PROJECT}.config worker -c 4 -l info
