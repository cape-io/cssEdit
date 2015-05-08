Hapi = require 'hapi'
_ = require 'lodash'
argv = require('minimist')(process.argv.slice(2))

server = new Hapi.Server {}

server.connection {
  port: if argv.site then 8081 else 8088
  routes:
    cors:
      additionalHeaders: ['X-Requested-With']
      override: false
}

SECOND = 1000
MINUTE = 60 * SECOND
HOUR = 60 * MINUTE
DAY = 86399999

server.route
  method: 'GET'
  path: '/theme/{path*}'
  handler: (request, reply) ->
    home = process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME']
    reply.file("#{home}/layouts/#{argv.layout}/#{request.params.path}")

proxySite = (request, reply) ->
  console.log request.url.path
  reply.proxy {
    passThrough: true
    mapUri: (req, cb) ->
      uri = 'http://'+argv.site+request.url.path
      cb(null, uri)
  }

server.ext 'onPreResponse', (request, reply) ->
  req = request.response
  if req.isBoom and (req.output.statusCode is 404)
    console.log '404'
    return proxySite(request, reply)
  return reply.continue()

server.route
  method: 'GET'
  path: '/{path*}'
  handler: proxySite

server.start ->
  console.log "info", "Server running at: " + server.info.uri
  return
