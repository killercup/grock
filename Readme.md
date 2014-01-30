# grock

[Grock](http://killercup.github.io/grock/) converts your nicely commented code into a gorgeous documentation where comments and code live happily next to each other.

To see how it works, just have a look at [the documentation rendered from this repository](http://killercup.github.io/grock/).

[![build status](https://travis-ci.org/killercup/grock.png?branch=master)](https://travis-ci.org/killercup/grock)
[![dependency version](https://david-dm.org/killercup/grock.png)](https://david-dm.org/killercup/grock)

## Install

Install globally using `npm install --global grock` and invoke anywhere using `grock --glob 'your/*.files'`.

Or use it as a (dev-)dependency in your project and use the `package.json` script section to run it, e.g. with `"scripts": {"docs": "grock"}` and using `npm run docs` (read more about this [here](task_automation_with_npm_run)).

## Usage

Basically:

```sh
$ grock --glob 'lib/**/*.js' --out 'docs' --verbose
```

For more information about available options, see `bin/grock` or run `grock --help`:

```md
$ grock --help
Usage: grock [options]

You can also use a configuration file named .groc.json to specify these options.

Options:
  --help        Show this message
  --version     Show grock version
  --glob        Set glob to match source files          [default: "lib/*.coffee"]
  --out         Render documentation into here          [default: "docs/"]
  --style       Set the output style/theme              [default: "solarized"]
  --verbose     Show more log output                    [default: false]
  --index       File to be used as index                [default: "Readme.md"]
  --root        The project's root directory            [default: "."]
  --github      Push generated docs to gh-pages branch  [default: false]
  --git-remote  Overwrite the remote for --github
```

For a list of supported languages, see the `lib/languages.coffee` file.

### Config File

You can specify all the command line options in a `.groc.json` file (that is compatible to [`groc`][groc]). This will automatically be loaded. This way you just need to save that file in your project directory and can use `grock` without arguments from now on.

### Auto Publish Documentation to Github Pages

Using the `--github` flag, `grock` will try to write the documentation not to an output directory, but to the `gh-pages` branch of your `git` repository. If it succeeds, it will immediately push the new changes to the `origin` remote (can be specified by `--git-remote`.

Assuming you have specified all other options in `./.groc.json`, you can then run:

```sh
$ grock --github
```

## Inspiration

- [Literate programming](http://en.wikipedia.org/wiki/Literate_programming) (the programming methodology coined by [Donald Knuth](http://en.wikipedia.org/wiki/Donald_Knuth))
- [Jeremy Ashkenas](https://github.com/jashkenas)' [docco]
- The [groc] project -- this implementation is heavily based on this, but uses node.js streams
- [Gulp.js](http://gulpjs.com/), a build system that uses streams to transform files

### What makes grock different?

In contrast to other node-based documentation generators like [docco], [groc], and [docker], grock has the following advantages:

- It doesn't need pygments.
- Therefore it doesn't need python.
- Therefore it's faster than those other tools that need pygments.
- It renders a file tree and also a headline tree for each document.
- The default style (based on solarized) is responsive and looks actually quite good on a phone.
- It's based on streams. I've heard all the cool kids are using streams now.

[docco]: http://jashkenas.github.com/docco/
[docker]: https://github.com/jbt/docker
[groc]: http://nevir.github.com/groc/

## Based on

- [vinyl-fs](https://github.com/wearefractal/vinyl-fs) for abstracting files
- [Solarized](http://ethanschoonover.com/solarized)
- [marked](https://github.com/chjj/marked)
- [highlight.js](http://highlightjs.org/)

Oh, and all the heavy lifting (splitting code and comments, parsing doc tags) is actually code from [groc](http://nevir.github.com/groc/)!

## Roadmap

- [x] Be awesome with streams
- [x] Split code and comments
- [x] Highlight code
- [x] Generate TOC as JSON file
- [x] Render doc tags (like jsdoc)
- [x] CLI docs, `.groc.json` config support
- [ ] Correctly parse relative roots
- [ ] Tests. Test for everything.
- [ ] Add another style.
- [ ] Find a streaming code highlighter with hooks for comment segments
- [x] Parse files without extension

## Contributing

Just fork the repo, implement some awesome feature or fix a bug and send a pull request.

### Code Style and Guideline

- Document your code.
- Write code in [CoffeeScript](http://coffeescript.org/) when possible and make sure [`coffeelint`](http://www.coffeelint.org/) doesn't throw any warning or errors.
- Make use of streams and promises. Those are good techniques.
- Split the code into as many independent, loosely coupled modules as possible and try to reuse existing ones.
- On the other hand, try to minimize (NPM) dependencies. Since this is a CLI tool, the startup time gets worse with every `require`.
- Run `npm test` before committing. (Currently, this runs `coffeelint` and `mocha`).

### Contributing to Styles

When adding a new style or editing an existing one, make sure you follow the guidelines in `styles/Readme.md` (e.g. adding an index file exporting copy, compile and template functions).

