#!/bin/bash
git config user.name "Travis-CI"
git config user.email "travis@pascalhertleif.de"
git remote set-url origin "https://${GH_TOKEN}@${GH_REF}" > /dev/null 2>&1

./bin/grock --verbose --github > /dev/null 2>&1
