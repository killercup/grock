# Grock Styles

## Contributing

All Styles should contain these files:

- `template.jade`: The HTML template from which the output will be generated
- `copy.{coffee|js}` exporting a copy method
  - Takes an Object with options, containing a `dest` property
  - Copies all assets needed for this style to `dest`
  - Returns promise that resolves when copy is done
- `compile.{coffee|js}` exporting a compile method; will be called before a publishing a new grock version
  - Takes an Object with options
  - Compiles all style assets into a directory, so that they can be easily copied later on when generatign the documentation (preventing the user to have to install `node-sass`, e.g.)
  - Returns promise that resolves when the compilation is done