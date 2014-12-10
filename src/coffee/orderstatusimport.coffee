_ = require 'underscore'
_.mixin require('underscore-mixins')
Promise = require 'bluebird'
{SphereClient, InventorySync} = require 'sphere-node-sdk'
package_json = require '../package.json'
xmlHelpers = require './xmlhelpers'

LOG_PREFIX = "[SphereOrderStatusImport] "

class OrderStatusImport

  constructor: (@logger, options = {}) ->
    @sync = new InventorySync
    @client = new SphereClient options
    @_resetSummary()

  _resetSummary: ->
    @summary =
      emptySKU: 0
      created: 0
      updated: 0

  run: (fileContent) ->
    @_resetSummary()
    @performXML fileContent

  summaryReport: (filename) ->
    if @summary.created is 0 and @summary.updated is 0
      message = 'Summary: nothing to do, everything is fine'
    else
      message = "Summary: there were #{@summary.created + @summary.updated} imported stocks " +
        "(#{@summary.created} were new and #{@summary.updated} were updates)"

    if @summary.emptySKU > 0
      warning = "Found #{@summary.emptySKU} empty SKUs from file input"
      warning += " '#{filename}'" if filename
      @logger.warn warning

    Promise.resolve(message)

  performXML: (fileContent) =>
    new Promise (resolve, reject) =>
      xmlHelpers.xmlTransform xmlHelpers.xmlFix(fileContent), (err, xml) =>
        if err?
          reject "#{LOG_PREFIX}Error on parsing XML: #{err}"
        else
          resolve()

module.exports = OrderStatusImport
