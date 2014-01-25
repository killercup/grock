#!/bin/bash
echo "Setting up git config"

CURRENT_COMMIT=`git rev-parse HEAD`

git config user.name "Travis-CI"
git config user.email "travis@pascalhertleif.de"

git clone -b gh-pages "https://${GH_TOKEN}@${GH_REF}" docs > /dev/null 2>&1 || exit 1

rm -r docs/*

echo "Compiling docs"
./bin/grock --verbose --out docs/ || exit 1

cd docs/

echo "Pushing to gh-pages"
git add -A
git commit -m "Generated documentation for $CURRENT_COMMIT" || exit 1
git push origin gh-pages > /dev/null 2>&1 || exit 1

echo "Pushed new documentation successfully."
exit 0