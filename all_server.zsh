#!/bin/zsh

DJANGO_OUT=~/Desktop/django.output
CELERY_OUT=~/Desktop/celery.output
NPM_OUT=~/Desktop/npm.output

django-admin runserver &> >(tee $DJANGO_OUT) &
celery -A yourproject worker -l info &> >(tee $CELERY_OUT) &
npm start &> >(tee $NPM_OUT) &
