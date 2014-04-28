# Changelog

## v0.3.3 Tirana Turtle

Mon Apr 28 2014

- Add support for parsing CSON files (Thanks, @erikmueller!)

## v0.3.2 Douglas Dog

Wed Mar 18 2014

- Add `whitespace-after-token` option (Thanks, @novemberborn!)

## v0.3.1 Cotonou Chameleon

Wed Feb 19 2014

- Fix RepositoryURL Fallback

## v0.3.0 Papeete Polar Bear

Mon Feb 10 2014

- Add _Thin_ style with bright colors and sharp fonts: [Screenshot](https://f.cloud.github.com/assets/20063/2121121/573a2af8-91d4-11e3-956a-a27ffd9a8635.png)
- Correctly link to latest source files on Github and Bitbucket (git repos)
- Add copyright and license doc tags

## v0.2.6 Dave Thesis

Sat Feb 08 2014

- Add `--indexes` option to generate subdirectory index files (default: `Readme.md` gets rendered as `index.html`)
- Fix doc tags order messing up markdown
- Automatically retrieve repository URL from `package.json`

## v0.2.5 Oscar Hera

Mon Feb 03 2014

- Adds nice error messages à la [plumber](https://github.com/floatdrop/gulp-plumber)
  - incl. file path
  - with stack traces on `--verbose`
- Add better page titles
- Fixes `index.js` and thus `require('grock')`

## v0.2.4 Jefferson Hemera

Sat Feb 01 2014

- Trim unnecessary newlines from highlighted code
- Fix searching headlines
- Improve tests and hopefully performance

## v0.2.3 Steel-Eye Demeter

Thu Jan 30 2014

- Render files without extension (treating them as JS)
- Trim HTML from headlines in TOC
- Always skip processing directories
- Don't crash on malformed doc tags
- Add more usage information to Readme file

## v0.2.2 Happy Erebus

Thu Jan 30 2014

- Precompile Templates
  - Enhances performance
  - Styles can use any templating library
- Solarized uses `lodash` templates now (this removes `jade` dependency)
- CoffeeScript 1.7 makes chained function calls more pretty (e.g. in streams and `.pipe`s)
- Speed things up a bit by skipping `highlight.js` and `marked` for files without code or comments (e.g. `.md` and `.json`)

## v0.2.1 Louis Hermes

Sun Jan 26 2014

- Script to publish to Github Pages branch
- Optimize writing of table of contents file

## v0.2.0 Earl Kaikias

Sat Jan 25 2014

- CLI arguments and `.groc.json` compliment each other
- Remove `gulp-util` dependency
- Solarized: Better responsive modes
- Solarized: Nicer directory index handling
- Solarized: Fix file title from headline
- Solarized: Readmes are fist files in directories

## v0.1.2 Dizzy Demeter

Mon Jan 20 2014

- Add missing log module

## v0.1.1 Dizzy Ares

Mon Jan 20 2014

- Add file path above document, link to currnt file in repository
- Add checkbox lists in markdown (using `[ ]` and `[x]` syntax)
- Fix some broken words (using CSS' word-break)

## v0.1.0 Clark Hades

Mon Jan 20 2014

_Initial release._

Features so far:

- Take code files, output html files
- Split code and comments
- Highlight code (even in comments)
- Generate TOC as JSON file
- Render doc tags (like jsdoc)
- CLI docs, `.groc.json` config support
- Default output style
  - Based on Solarized
  - Searchable file and headline list
  - Responsive layout

