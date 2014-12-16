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

  run: (fileContent) ->
    @performXML fileContent

  performXML: (fileContent) =>
    new Promise (resolve, reject) =>
      xmlHelpers.xmlTransform xmlHelpers.xmlFix(fileContent), (err, xml) =>
        if err?
          reject "#{LOG_PREFIX}Error on parsing XML: #{err}"
        else
          @_mapXML xml.order
          .then (result) -> resolve result
          .catch (err) -> reject err
          .done()

  _parcelExists: (order, trackingId) ->
    result = _.chain(order.shippingInfo.deliveries)
    .map (delivery) -> delivery.parcels
    .flatten()
    .find (parcel) -> parcel.trackingData.trackingId is trackingId
    .some()
    .value()

  _mapXML: (orderStatus) =>
    @client.orders.where("orderNumber=\"#{orderStatus.orderNumber}\"").fetch()
    .then (result) =>
      originalOrder = result.body.results[0]

      if result.body.total == 0
        Promise.reject "#{LOG_PREFIX} No order found with orderNumber '#{orderStatus.orderNumber}'."
      else if result.body.total == 1
        changedOrder = @_mergeOrder originalOrder, orderStatus

        # compute update actions
        syncedActions = @sync.buildActions changedOrder, originalOrder

        if syncedActions.shouldUpdate()
          @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
        else
          Promise.resolve statusCode: 304

  _mergeOrder: (originalOrder, orderStatus) ->
    changedOrder = _.deepClone originalOrder

    # FIX: convert boolean string representation to booelan value
    # CHECK
    orderStatus.shippingInfo.deliveries.parcels.trackingData.isReturn =
      if orderStatus.shippingInfo.deliveries.parcels.trackingData.isReturn == 'true' then true else false

    changedOrder.orderState = orderStatus.orderState
    changedOrder.shipmentState = orderStatus.shipmentState

    # check if there is already a parcel with that tracking id
    if not @_parcelExists originalOrder, orderStatus.shippingInfo.deliveries.parcels.trackingData.trackingId
      # add delivery
      changedOrder.shippingInfo.deliveries.push
        'parcels': [orderStatus.shippingInfo.deliveries.parcels]
        # we assume that all lineitems are sent with this parcel
        'items': _.map originalOrder.lineItems, (item) ->
          id: item.id
          quantity: item.quantity

    changedOrder

module.exports = OrderStatusImport
