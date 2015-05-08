Hapi = require 'hapi'

module.exports = (url, layout, home) ->
  server = new Hapi.Server {}

  server.connection {
    port: 8081
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
      reply.file("#{home}/Sites/layouts/#{layout}/public/#{request.params.path}")

  proxySite = (request, reply) ->
    reply.proxy {
      passThrough: true
      mapUri: (req, cb) ->
        uri = 'http://'+url+request.url.path
        cb(null, uri)
    }

  server.ext 'onPreResponse', (request, reply) ->
    req = request.response
    if req.isBoom and (req.output.statusCode is 404)
      console.error "404: #{home}/Sites/layouts/#{layout}/public/#{request.params.path}"
      return proxySite(request, reply)
    return reply.continue()

  server.route
    method: 'GET'
    path: '/{path*}'
    handler: proxySite

  server.start ->
    console.log "info", "Server running at: " + server.info.uri
    return

  return
