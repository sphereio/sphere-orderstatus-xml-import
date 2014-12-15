_ = require 'underscore'
_.mixin require('underscore-mixins')
Promise = require 'bluebird'
{ExtendedLogger} = require 'sphere-node-utils'
package_json = require '../package.json'
Config = require '../config'
xmlHelpers = require '../lib/xmlhelpers.js'
OrderStatusImport = require '../lib/orderstatusimport'

describe 'OrderStatusImport', ->
  beforeEach ->
    logger = new ExtendedLogger
      logConfig:
        name: "#{package_json.name}-#{package_json.version}"
        streams: [
          { level: 'info', stream: process.stdout }
        ]
    @import = new OrderStatusImport logger,
      config: Config.config

  it 'should initialize', ->
    expect(@import).toBeDefined()

  it "should return true if an parcel with given tracking already exists", ->

    trackingId = '10000000000000'

    order =
      shippingInfo:
        deliveries: [
          parcels: [
            trackingData:
              trackingID: trackingId
          ]
        ]

    parcelExists = @import._parcelExists order, trackingId
    expect(parcelExists).toMatch(true)

  it "should return false if an parcel with given tracking not exists", ->

    trackingId = '10000000000000'

    order =
      shippingInfo:
        deliveries: []

    parcelExists = @import._parcelExists order, trackingId
    expect(parcelExists).toMatch(false)
