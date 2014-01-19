# grock

Grock converts your nicely commented code into a gorgeous documentation where comments and code live happily next to each other.

## Inspiration

- [Literate programming](http://en.wikipedia.org/wiki/Literate_programming) (the programming methodology coined by [Donald Knuth](http://en.wikipedia.org/wiki/Donald_Knuth))
- [Jeremy Ashkenas](https://github.com/jashkenas)' [docco](http://jashkenas.github.com/docco/)
- The [groc](http://nevir.github.com/groc/) project -- this implementation is heavily based on this, but uses node.js streams

## Implementation

Basically:

```coffee
bufferedFileStream(['*/**.{js,coffee}'])
.pipe(highlight())
.pipe(splitCodeAndComments())
.pipe(markdownComments())
.pipe(highlightCodeInComments())
.pipe(buildFileTreeAndFileTOC())
.pipe(renderTemplates(style: 'solarized'))
.pipe(outputAsHTMLFile('docs/'))
```
