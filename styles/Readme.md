# Grock Styles

## Contributing

All Styles should contain an index files exporting these properties:

- `template` (String): The path to a Jade template from which the output will be generated
- `copy(opts)`: a copy method
  - Takes an Object of options, containing a `dest` property
  - Copies all assets needed for this style to `dest`
  - Returns a promise that resolves when copy is done
- `compile(opts)`: a compile method; will be called before publishing a new grock version
  - Takes an Object of options
  - Compiles all style assets into a directory, so that they can be easily copied later on when generating the documentation (preventing the user to have to install `node-sass`, e.g.)
  - Returns a promise that resolves when the compilation is done

After changing style assets, you need to execute the compile function. To recompile all styles, use `npm run compile-styles`.
