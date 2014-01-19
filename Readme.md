# grock

Grock converts your nicely commented code into a gorgeous documentation where comments and code live happily next to each other.

## Inspiration

- [Literate programming](http://en.wikipedia.org/wiki/Literate_programming) (the programming methodology coined by [Donald Knuth](http://en.wikipedia.org/wiki/Donald_Knuth))
- [Jeremy Ashkenas](https://github.com/jashkenas)' [docco](http://jashkenas.github.com/docco/)
- The [groc](http://nevir.github.com/groc/) project -- this implementation is heavily based on this, but uses node.js streams

## Uses

- [vinyl-fs](https://github.com/wearefractal/vinyl-fs) for abstracting files
- [Solarized](http://ethanschoonover.com/solarized)
- [marked](https://github.com/chjj/marked)
- [highlight.js](http://highlightjs.org/)

## Roadmap

- [x] Be awesome with streams
- [x] Split code and comments
- [x] Highlight code
- [ ] Generate TOC as JSON file
- [ ] Render doc tags (like jsdoc)
- [ ] CLI docs, `.groc.json` config support
- [ ] Tests. Test for everything.
- [ ] Add another style.
