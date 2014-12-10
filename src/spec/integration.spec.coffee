_ = require 'underscore'
_.mixin require('underscore-mixins')
Promise = require 'bluebird'
{ExtendedLogger} = require 'sphere-node-utils'
package_json = require '../package.json'
Config = require '../config'
OrderStatusImport = require '../lib/orderstatusimport'

cleanup = (logger, client) ->
  logger.debug 'Deleting old inventory entries...'
  client.inventoryEntries.all().fetch()
  .then (result) ->
    Promise.all _.map result.body.results, (e) ->
      client.inventoryEntries.byId(e.id).delete(e.version)
  .then (results) ->
    logger.debug "#{_.size results} deleted."
    Promise.resolve()

describe 'integration test', ->

  beforeEach (done) ->
    @logger = new ExtendedLogger
      additionalFields:
        project_key: Config.config.project_key
      logConfig:
        name: "#{package_json.name}-#{package_json.version}"
        streams: [
          { level: 'info', stream: process.stdout }
        ]
    @orderstatusimport = new OrderStatusImport @logger,
      config: Config.config

    @client = @orderstatusimport.client

    @logger.info 'About to setup...'
    cleanup(@logger, @client)
    .then -> done()
    .catch (err) -> done(_.prettify err)
  , 10000 # 10sec

  afterEach (done) ->
    @logger.info 'About to cleanup...'
    cleanup(@logger, @client)
    .then -> done()
    .catch (err) -> done(_.prettify err)
  , 10000 # 10sec

  describe 'XML file', ->

    it 'Nothing to do', (done) ->
      @orderstatusimport.run('<root></root>')
      .then => done()
      #@orderstatusimport.summaryReport()
      #.then (message) ->
    #    expect(message).toBe 'Summary: nothing to do, everything is fine'
    #    done()
      .catch (err) -> done(_.prettify err)
    , 10000 # 10sec
