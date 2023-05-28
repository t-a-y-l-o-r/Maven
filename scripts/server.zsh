#!/bin/zsh

PROJECT_NAME=$(basename $(pwd))

DJANGO_OUT=~/Desktop/django.output
CELERY_OUT=~/Desktop/celery.output
NPM_OUT=~/Desktop/npm.output

django-admin runserver_plus &> >(tee $DJANGO_OUT) &
poetry run celery -A $PROJECT_NAME.config worker -c 4 -l info &> >(tee $CELERY_OUT) & \
  poetry run celery -A $PROJECT_NAME.config beat --schedule=/tmp/celerybeat-schedule
npm run dev &> >(tee $NPM_OUT) &
