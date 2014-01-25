#!/bin/bash
rm -rf docs || exit 0;

CURRENT_COMMIT=`git rev-parse HEAD`

./bin/grock --verbose --out docs/

( cd docs
  git init
  git config user.name "Travis-CI"
  git config user.email "travis@pascalhertleif.de"
  git add .
  git commit -m "Documentation for ${CURRENT_COMMIT}"
  git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1
)