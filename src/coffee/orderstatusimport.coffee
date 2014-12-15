_ = require 'underscore'
_.mixin require('underscore-mixins')
Promise = require 'bluebird'
{SphereClient, OrderSync} = require 'sphere-node-sdk'
package_json = require '../package.json'
xmlHelpers = require './xmlhelpers'

LOG_PREFIX = "[SphereOrderStatusImport] "

class OrderStatusImport

  constructor: (@logger, options = {}) ->
    @sync = new OrderSync
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

  performXML: (fileContent) =>
    new Promise (resolve, reject) =>
      xmlHelpers.xmlTransform xmlHelpers.xmlFix(fileContent), (err, xml) =>
        if err?
          reject "#{LOG_PREFIX}Error on parsing XML: #{err}"
        else
          @_mapXML xml.order
          resolve()

  _parcelExists: (order, trackingId) ->
    result = _.chain(order.shippingInfo.deliveries)
    .map (delivery) -> delivery.parcels
    .flatten()
    .find (parcel) -> parcel.trackingData.trackingID is trackingId
    .some()
    .value()

  _mapXML: (orderStatus) =>
    if orderStatus?
      @client.orders.where("orderNumber=\"#{orderStatus.orderNumber}\"").fetch()
      .then (result) =>
        originalOrder = result.body.results[0]

        changedOrder = @_mergeOrderStatus originalOrder, orderStatus

        # compute update actions
        syncedActions = @sync.buildActions changedOrder, originalOrder

        if syncedActions.shouldUpdate()
          @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
        else
          Promise.resolve statusCode: 304

  _mergeOrderStatus: (originalOrder, orderStatus) ->
    changedOrder = _.deepClone originalOrder

    # FIX: xml contains 'Completed' instead of allow value 'Complete'
    orderStatus.orderState = 'Complete' if orderStatus.orderState == 'Completed'

    # FIX: convert boolean string representation to booelan value
    orderStatus.shippingInfo.deliveries.parcels.trackingData.isReturn =
      if orderStatus.shippingInfo.deliveries.parcels.trackingData.isReturn.isReturn == 'true' then true else false

    changedOrder.orderState = orderStatus.orderState
    changedOrder.shipmentState = orderStatus.shipmentState

    # check if there is already a parcel with that tracking id
    if not @_parcelExists originalOrder, orderStatus.shippingInfo.deliveries.parcels.trackingData
      # add delivery
      changedOrder.shippingInfo.deliveries.push
        'parcels': [orderStatus.shippingInfo.deliveries.parcels]
        # we assume that all lineitems are sent with this parcel
        'items': _.map originalOrder.lineItems, (item) ->
          id: item.id
          quantity: item.quantity

    changedOrder

module.exports = OrderStatusImport
