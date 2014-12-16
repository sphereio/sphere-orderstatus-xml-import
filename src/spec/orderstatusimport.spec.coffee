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
              trackingId: trackingId
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
    expect(parcelExists).toMatch false

  it "should merge order status with given order", ->

    order =
      type: 'Order'
      id: '3ca388b0-1d7f-4496-b60b-3eafa90cdc39'
      version: 28
      orderNumber: '100790'
      customerId: '123123123123'
      customerEmail: 'test@commercetools.de'
      createdAt: '2014-05-06T17:46:01.514Z'
      lastModifiedAt: '2014-12-14T20:49:42.800Z'
      orderState: 'Open'
      shipmentState: 'Pending'
      paymentState: 'Pending'
      totalPrice:
        currencyCode: 'EUR'
        centAmount: 999
      shippingInfo:
        deliveries: []
      lineItems: [
        {
          id: '1000001'
          quantity: 1
        },
        {
          id: '1000002'
          quantity: 2
        }
      ]

    orderStatus =
      xsdVersion: '0.3'
      orderNumber: '100790'
      orderState: 'Complete'
      shipmentState: 'Shipped'
      shippingInfo:
        deliveries:
          parcels:
            trackingData:
              trackingId: '00340434152712408817'
              carrier: 'DHL'
              isReturn: 'false'

    expectedMergedOrder =
      type: 'Order'
      id: '3ca388b0-1d7f-4496-b60b-3eafa90cdc39'
      version: 28
      orderNumber: '100790'
      customerId: '123123123123'
      customerEmail: 'test@commercetools.de'
      createdAt: '2014-05-06T17:46:01.514Z'
      lastModifiedAt: '2014-12-14T20:49:42.800Z'
      orderState: 'Complete'
      shipmentState: 'Shipped'
      paymentState: 'Pending'
      totalPrice:
        currencyCode: 'EUR'
        centAmount: 999
      shippingInfo:
        deliveries: [
          parcels: [
            trackingData:
              trackingId: '00340434152712408817'
              carrier: 'DHL'
              isReturn: false
          ]
          items: [
            {
              id: '1000001'
              quantity: 1
            },
            {
              id: '1000002'
              quantity: 2
            }
          ]
        ]
      lineItems: [
        {
          id: '1000001'
          quantity: 1
        },
        {
          id: '1000002'
          quantity: 2
        }
      ]

    mergedOrder = @import._mergeOrder order, orderStatus

    expect(mergedOrder).toEqual expectedMergedOrder

  it "should merge order status with given order without already created parcel /w trackingId", ->
    order =
      type: 'Order'
      id: '3ca388b0-1d7f-4496-b60b-3eafa90cdc39'
      version: 28
      orderNumber: '100790'
      customerId: '123123123123'
      customerEmail: 'test@commercetools.de'
      createdAt: '2014-05-06T17:46:01.514Z'
      lastModifiedAt: '2014-12-14T20:49:42.800Z'
      orderState: 'Open'
      shipmentState: 'Pending'
      paymentState: 'Pending'
      totalPrice:
        currencyCode: 'EUR'
        centAmount: 999
      shippingInfo:
        deliveries:
          [
            {
              items: [
                {
                  id: '1000001'
                  quantity: 1
                },
                {
                  id: '1000002'
                  quantity: 2
                },
              ]
              parcels: [
                {
                  trackingData:
                    trackingId: '00340434152712408817'
                    carrier: 'DHL'
                    isReturn: false
                }
              ]
            }
          ]
      lineItems: [
        {
          id: '1000001'
          quantity: 1
        },
        {
          id: '1000002'
          quantity: 2
        }
      ]

    orderStatus =
      xsdVersion: '0.3'
      orderNumber: '100790'
      orderState: 'Complete'
      shipmentState: 'Shipped'
      shippingInfo:
        deliveries:
          parcels:
            trackingData:
              trackingId: '00340434152712408817'
              carrier: 'DHL'
              isReturn: 'false'

    expectedMergedOrder =
      type: 'Order'
      id: '3ca388b0-1d7f-4496-b60b-3eafa90cdc39'
      version: 28
      orderNumber: '100790'
      customerId: '123123123123'
      customerEmail: 'test@commercetools.de'
      createdAt: '2014-05-06T17:46:01.514Z'
      lastModifiedAt: '2014-12-14T20:49:42.800Z'
      orderState: 'Complete'
      shipmentState: 'Shipped'
      paymentState: 'Pending'
      totalPrice:
        currencyCode: 'EUR'
        centAmount: 999
      shippingInfo:
        deliveries: [
          items: [
            {
              id: '1000001'
              quantity: 1
            },
            {
              id: '1000002'
              quantity: 2
            }
          ]
          parcels: [
            trackingData:
              trackingId: '00340434152712408817'
              carrier: 'DHL'
              isReturn: false
          ]
        ]
      lineItems: [
        {
          id: '1000001'
          quantity: 1
        },
        {
          id: '1000002'
          quantity: 2
        }
      ]

    mergedOrder = @import._mergeOrder order, orderStatus

    expect(mergedOrder).toEqual expectedMergedOrder
