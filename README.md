# Nockingbird

Nockingbird is an interface for [Nock][1]. With Nockingbird, mocks are
specified in straightforward text files, rather than in JavaScript code.

Example from the Nock [documentation][2]:

```javascript
var scope = nock('http://myapp.iriscouch.com')
                .get('/users/1')
                .reply(404)
                .post('/users', {
                  username: 'pgte',
                  email: 'pedro.teixeira@gmail.com'
                })
                .reply(201, {
                  ok: true,
                  id: '123ABC',
                  rev: '946B7D1C'
                })
                .get('/users/123ABC')
                .reply(200, {
                  _id: '123ABC',
                  _rev: '946B7D1C',
                  username: 'pgte',
                  email: 'pedro.teixeira@gmail.com'
                });
```

The equivalent Nockingbird file is as follows:

    -- chaining-example.nb

    >> GET /users/1
    << 404

    >> POST /users
    >>   username=pgte
    >>   email=pedro.teixeira%40gmail.com
    << 201
    << content-type: application/json
    << ={"ok":true,"id":"123ABC","rev":"946B7D1C"}

    >> GET /users/123ABC
    << 200
    << content-type: application/json
    << ={"_id":"123ABC","_rev":"946B7D1C","username":"pgte","email":"pedro.teixeira@gmail.com"}

__nockingbird.load__ can be used to apply the declarations in a Nockingbird
file to a Nock scope object:

```javascript
var nock = require('nock');
var nockingbird = require('nockingbird');

var scope = nock('http://myapp.iriscouch.com');
nockingbird.load(scope, __dirname + '/mocks/chaining-example.nb');
```

### File format

Nockingbird files consist of zero or more "chunks". A file's text is broken
into chunks according to the delimiter `\n\n`. Each line within a chunk must
begin with `>>`, `<<`, or `--`. `>>` is for requests; `<<` is for responses.
Lines beginning with `--` are ignored. For example:

```
-- Retrieve John's account details from the /users endpoint.
>> GET /users/1
<< 200
<< content-type: application/json
<< ={"id":"1","username":"jsmith","email":"jsmith@example.com"}
```

The extension for the Nockingbird file format is `.nb`.

#### Chunks

Each chunk must conform to the following grammar:

```ebnf
chunk               = request lines , response lines ;
```

#### Request lines

Each chunk must contain one or more request lines (lines beginning with `>>`),
in accordance with the following grammar:

```ebnf
request lines       = main request line , { form data line } ;
main request line   = request prefix , method name , pathname , "\n" ;
method name         = "GET" | "POST" | "PUT" | "HEAD" | "PATCH" | "MERGE" | "DELETE" ;
pathname            = { any character } ;
form data line      = request prefix , param name , "=" , param value , "\n" ;
param name          = { any character } ;
param value         = { any character } ;
request prefix      = ">>" , { " " } ;
any character       = ? any character except "\n" ? ;
```

#### Response lines

Each chunk must contain two or more response lines (lines beginning with `<<`),
in accordance with the following grammar:

```ebnf
response lines      = status code line , { header line } , response body ;
status code line    = response prefix , status code , "\n" ;
status code         = digit , { digit } ;
digit               = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
header line         = response prefix , header name , ":" , { " " } , header value , "\n" ;
header name         = { any character } ;
header value        = { any character } ;
response body       = inline body | filename line ;
inline body         = inline body line , { inline body line } ;
inline body line    = response prefix , "=" , { any character } , "\n" ;
filename line       = response prefix , { any character } , "\n" ;
response prefix     = "<<" , { " " } ;
any character       = ? any character except "\n" ? ;
```


[1]: https://github.com/pgte/nock
[2]: https://github.com/pgte/nock#chaining
