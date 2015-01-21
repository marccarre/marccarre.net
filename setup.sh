#!/bin/bash
if ! [[ $(git remote) =~ "heroku" ]]; then

  project=$(basename $PWD)
  git remote add heroku git@heroku.com:$project.git
  heroku git:remote -a $project
  echo "[SUCCESS] Configured project for deployment to Heroku."

  if ! [[ -f .env ]]; then
    touch .env
  fi
  echo "[WARNING] Please configure .env with the required variable among:"
  heroku config
  echo # newline
fi

if [[ -f .env ]]; then
  source .env
fi

rake db:drop && rake db:create:all && rake db:migrate && rake db:seed
rails server
