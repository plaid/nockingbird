fs = require 'fs'
path = require 'path'

_ = require 'underscore'


is_method_name = _.partial _.contains, [
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

  [main_request_line, form_data_lines...] = request_lines
  [method_name, pathname] = main_request_line.split /[ ]+/
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

  scope[method_name.toLowerCase()](
    pathname
    [form_data_lines.join '&'].filter(Boolean)...
  )[if filename? then 'replyWithFile' else 'reply'](
    status_code_line
    if filename?
      path.resolve root, filename
    else
      response_body_lines.join '\n'
    _.object _.map response_header_lines,
                   _.compose _.rest, RegExp::exec.bind /^([^:]*):[ ]*(.*)$/
  )
  return


exports.load = (scope, filename, root) ->
  fs.readFileSync filename, 'utf8'
  .replace /^\s*--.*$\n?/gm, ''
  .split /\n{2,}/
  .forEach _.partial exports.mock, scope, _, root
  return
