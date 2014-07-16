assert = require 'assert'

nock = require 'nock'

nockingbird = require '..'


dummy = nock 'http://example.com'
class Scope then constructor: -> @__log__ = []
[Object.keys(dummy)..., Object.keys(dummy.get('/'))...].forEach (key) ->
  Scope.prototype[key] = (args...) -> @__log__.push [key, args...]; this


describe 'nockingbird.load', ->

  it 'parses hello-world.nb', ->
    scope = new Scope
    nockingbird.load scope, __dirname + '/nb/hello-world.nb'
    assert.deepEqual scope.__log__, [
      ['get', '/']
      ['reply', 200, 'Hello, world!', {}]
    ]

  it 'parses response-headers.nb', ->
    scope = new Scope
    nockingbird.load scope, __dirname + '/nb/response-headers.nb'
    assert.deepEqual scope.__log__, [
      ['get', '/']
      ['reply', 200, 'hai!', {
        'content-type': 'text/plain'
        'content-length': '4'
      }]
    ]

  it 'parses request-methods.nb', ->
    scope = new Scope
    nockingbird.load scope, __dirname + '/nb/request-methods.nb'
    assert.deepEqual scope.__log__, [
      ['get', '/']
      ['reply', 200, 'GET request successful', {}]
      ['post', '/']
      ['reply', 200, 'POST request successful', {}]
      ['put', '/']
      ['reply', 200, 'PUT request successful', {}]
      ['head', '/']
      ['reply', 200, '', {}]
      ['patch', '/']
      ['reply', 200, 'PATCH request successful', {}]
      ['merge', '/']
      ['reply', 200, 'MERGE request successful', {}]
      ['delete', '/']
      ['reply', 200, 'DELETE request successful', {}]
    ]

  it 'parses reply-with-file.nb', ->
    scope = new Scope
    nockingbird.load scope, __dirname + '/nb/reply-with-file.nb', '/tmp'
    assert.deepEqual scope.__log__, [
      ['get', '/']
      ['replyWithFile', 200, '/tmp/index.html', {}]
    ]

  it 'parses comments.nb', ->
    scope = new Scope
    nockingbird.load scope, __dirname + '/nb/comments.nb'
    assert.deepEqual scope.__log__, [
      ['get', '/1']
      ['reply', 200, '--one--', {}]
      ['get', '/2']
      ['reply', 200, '--two--', {}]
    ]

  it 'throws while parsing invalid-chunk.nb', ->
    scope = new Scope
    assert.throws ->
      nockingbird.load scope, __dirname + '/nb/invalid-chunk.nb'
    , (err) ->
      err.constructor is SyntaxError and
      err.message is 'Invalid chunk (lines must begin with ">>" or "<<")'

  it 'throws while parsing invalid-request-method.nb', ->
    scope = new Scope
    assert.throws ->
      nockingbird.load scope, __dirname + '/nb/invalid-request-method.nb'
    , (err) ->
      err.constructor is Error and
      err.message is 'Invalid request method "get"'

  it 'ensures status code is a number', ->
    scope = new Scope
    nockingbird.load scope, __dirname + '/nb/hello-world.nb'
    assert.strictEqual scope.__log__[1][1], 200
