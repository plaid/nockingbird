fs = require 'fs'
path = require 'path'

R = require 'ramda'


is_method_name = R.rPartial R.contains, [
  'GET'
  'POST'
  'PUT'
  'HEAD'
  'PATCH'
  'MERGE'
  'DELETE'
]

exports.mock = (scope, chunk, root) ->
  request_lines = []; response_lines = []
  chunk
  .replace /\n+$/, ''
  .split /\n/
  .map RegExp::exec.bind /^(>>|<<)\s*(.*)$/
  .forEach (match) ->
    if match is null
      throw new SyntaxError 'Invalid chunk (lines must begin with ">>" or "<<")'
    else
      (if match[1] is '>>' then request_lines else response_lines).push match[2]

  [method_name, pathname] = request_lines[0].split /[ ]+/
  unless is_method_name method_name
    throw new Error "Invalid request method \"#{method_name}\""

  [status_code_line, other_response_lines...] = response_lines
  [response_header_lines, response_body_lines, filename] =
    other_response_lines.reduce ([header_lines, body_lines], line, idx) ->
      if match = /^=(.*)$/.exec line
        [header_lines, [body_lines..., match[1]]]
      else if idx is other_response_lines.length - 1
        [header_lines, body_lines, line]
      else
        [[header_lines..., line], body_lines]
    , [[], []]

  scope[method_name.toLowerCase()].apply(
    scope,
    R.pipe(
      R.tail
      R.map RegExp::exec.bind /^=(.*)$/
      R.pluck '1'
      R.join '\n'
      R.of
      R.reject R.isEmpty
      R.concat [pathname]
    ) request_lines
  )[if filename? then 'replyWithFile' else 'reply'](
    Number status_code_line
    if filename?
      path.resolve root, filename
    else
      response_body_lines.join '\n'
    R.pipe(
      R.map RegExp::exec.bind /^([^:]*):[ ]*(.*)$/
      R.map R.tail
      R.fromPairs
    ) response_header_lines
  )
  return


exports.load = (scope, filename, root) ->
  fs.readFileSync filename, 'utf8'
  .replace /^\s*--.*$\n?/gm, ''
  .split /\n{2,}/
  .filter Boolean
  .forEach (chunk) -> exports.mock scope, chunk, root
  return
