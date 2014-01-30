# About Grock Styles

## Contributing

All Styles should contain an index files exporting these properties:

- `String getTemplate(Object context)`: Return a render function
  - A function returning a render function that
    - takes an `templateContext` Object (created in `libs/tranforms/renderTemplates`)
    - returns the string representation of the rendered HTML document.
  - (This can also be the compiled version of a template, using `lodash`, `jade` or similar libraries.)
- `Promise copy(Object opts)`: a copy method
  - Takes an Object of options, containing a `dest` property
  - Copies all assets needed for this style to `dest`
  - Returns a promise that resolves when copy is done
- `Promise compile(Object opts)`: a compile method; will be called before publishing a new grock version
  - Takes an Object of options
  - Compiles all style assets into a directory, so that they can be easily copied later on when generating the documentation (preventing the user to have to install `node-sass`, e.g.)
  - Returns a promise that resolves when the compilation is done

After changing style assets, you need to execute the compile function. To recompile all styles, use `npm run compile-styles`.
