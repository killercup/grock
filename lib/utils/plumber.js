/**
 * # Plumber
 *
 * Code from [`gulp-plumber`][1]
 *
 * @copyright Vsevolod Strukchinsky <floatdrop@gmail.com>
 *
 * [1]: https://github.com/floatdrop/gulp-plumber/blob/f1c10cb6f4e0a6b957514a64500a9c8c48aff546/index.js
 */

/*globals module, require*/

var EE = require('events').EventEmitter;
var Through = require('event-stream').through;
var colors = require('chalk');

var log = require('./log');

function removeDefaultHandler(stream, event) {
  var found = false;
  stream.listeners(event).forEach(function (item) {
    if (item.name === 'on' + event) {
      found = item;
      this.removeListener(event, item);
    }
  }, stream);
  return found;
}

function wrapPanicOnErrorHandler(stream) {
  var oldHandler = removeDefaultHandler(stream, 'error');
  if (oldHandler) {
    stream.on('error', function onerror2(er) {
      if (EE.listenerCount(stream, 'error') === 1) {
        this.removeListener('error', onerror2);
        oldHandler.call(stream, er);
      }
    });
  }
}

function defaultErrorHandler(error) {
  // onerror2 and this handler
  if (EE.listenerCount(this, 'error') < 3) {
    log(
      colors.red('Failed!'),
      error.toString().trim().replace(/^Error: /, '') +
      (error.file ? ' '+ colors.magenta(error.file) : '')
    );

    if (error.stack)
      log.verbose(colors.red('Stack:'), error.stack);
  }
}

function plumber(opts) {
  opts = opts || {};

  var through = new Through(function (file) { this.queue(file); });
  through._plumber = true;

  if (opts.errorHandler !== false) {
    through.errorHandler = (typeof opts.errorHandler === 'function') ?
      opts.errorHandler :
      defaultErrorHandler;
  }

  function patchPipe(stream) {
    if (stream.pipe2) {
      wrapPanicOnErrorHandler(stream);
      stream._pipe = stream._pipe || stream.pipe;
      stream.pipe = stream.pipe2;
      stream.once('readable', patchPipe.bind(null, stream));
      stream._plumbed = true;
    }
  }

  through.pipe2 = function pipe2(dest) {

    if (!dest) { throw new Error('Can\'t pipe to undefined'); }

    this._pipe.apply(this, arguments);
    removeDefaultHandler(this, 'error');

    if (dest._plumber) { return dest; }

    dest.pipe2 = pipe2;

    // Patching pipe method
    if (opts.inherit !== false) {
      patchPipe(dest);
    }

    // Placing custom on error handler
    if (this.errorHandler) {
      dest.errorHandler = this.errorHandler;
      dest.on('error', this.errorHandler.bind(dest));
    }

    dest._plumbed = true;

    return dest;
  };

  patchPipe(through);

  return through;
}

module.exports = plumber;
