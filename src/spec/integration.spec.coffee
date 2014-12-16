_ = require 'underscore'
_.mixin require('underscore-mixins')
Promise = require 'bluebird'
{ExtendedLogger} = require 'sphere-node-utils'
package_json = require '../package.json'
Config = require '../config'
OrderStatusImport = require '../lib/orderstatusimport'
{SphereClient} = require 'sphere-node-sdk'

describe 'integration test', ->
  
  jasmine.getEnv().defaultTimeoutInterval = 10000

  beforeEach (done) ->

    @orderstatusimport = new OrderStatusImport @logger,
      config: Config.config

    @client = @orderstatusimport.client

    # get a tax category required for setting up shippingInfo (simply returning first found)
    @client.taxCategories.create(taxCategoryMock())
    .then (result) =>
      @taxCategory = result.body
      @client.zones.create(zoneMock())
    .then (result) =>
      @zone = result.body
      @client.shippingMethods.create(shippingMethodMock(@zone, @taxCategory))
    .then (result) =>
      @shippingMethod = result.body
      @client.productTypes.create(productTypeMock())
    .then (result) =>
      @productType = result.body
      @client.products.create(productMock(@productType))
    .then (result) =>
      @product = result.body
      @client.orders.import(orderMock(@shippingMethod, @product, @taxCategory))
    .then (result) =>
      @order = result.body
      done()
    .catch (error) -> done(_.prettify(error))

  afterEach (done) ->

    # TODO: delete order (not supported by API yet)
    @client.products.byId(@product.id).delete(@product.version)
    .then (result) =>
      @client.productTypes.byId(@productType.id).delete(@productType.version)
    .then (result) -> done()
    .catch (error) -> done(_.prettify(error))
    .finally =>
      @product = null
      @productType = null
      @order = null

  describe 'Update order state', ->

    it 'it should update orderState, shipmentState and shippingInfo of an existing order', (done) ->
      trackingId = uniqueId 't-'
      carrier = 'DHL'
      isReturn = false
      @orderstatusimport.run orderStateMock(@order.orderNumber, trackingId, carrier, isReturn)
      .then =>
        @client.orders.byId(@order.id).fetch()
      .then (result) ->
        expect(result.statusCode).toBe 200
        expect(result.body.orderState).toBe 'Complete'
        expect(result.body.shipmentState).toBe 'Shipped'
        expect(result.body.shippingInfo.deliveries.length).toBe 1
        expect(result.body.shippingInfo.deliveries[0].parcels[0].trackingData.carrier).toBe carrier
        expect(result.body.shippingInfo.deliveries[0].parcels[0].trackingData.trackingId).toBe trackingId
        expect(result.body.shippingInfo.deliveries[0].parcels[0].trackingData.isReturn).toBe isReturn
        done()
      .catch (err) -> done(_.prettify err)

    it 'it should update orderState, shipmentState and shippingInfo of an existing order', (done) ->
      trackingId = uniqueId 't-'
      carrier = 'DHL'
      isReturn = false
      @orderstatusimport.run orderStateMock('unavailable', trackingId, carrier, isReturn)
      .catch (err) ->
        expect(err).toBe '[SphereOrderStatusImport]  No order found with orderNumber \'unavailable\'.'
        done()

    it 'it should update orderState, shipmentState and shippingInfo of an existing order only once', (done) ->
      trackingId = uniqueId 't-'
      carrier = 'DHL'
      isReturn = false
      @orderstatusimport.run orderStateMock(@order.orderNumber, trackingId, carrier, isReturn)
      .then =>
        @client.orders.byId(@order.id).fetch()
      .then (result1) =>
        @result1 = result1
        expect(result1.statusCode).toBe 200
        @orderstatusimport.run orderStateMock(@order.orderNumber, trackingId, carrier, isReturn)
      .then (result2) =>
        expect(result2.statusCode).toBe 304
      .then =>
        @client.orders.byId(@order.id).fetch()
      .then (result3) =>
        expect(result3.statusCode).toBe 200
        expect(result3.body.version).toBe @result1.body.version
        done()
      .catch (err) -> done(_.prettify err)

  ###
  helper methods
  ###

  orderStateMock = (orderNumber, trackingId, carrier, isReturn) ->
    """
    <order>
      <xsdVersion>0.3</xsdVersion>
      <orderNumber>#{orderNumber}</orderNumber>
      <orderState>Complete</orderState>
      <shipmentState>Shipped</shipmentState>
      <shippingInfo>
        <deliveries>
          <parcels>
            <trackingData>
              <trackingId>#{trackingId}</trackingId>
              <carrier>#{carrier}</carrier>
              <isReturn>#{isReturn}</isReturn>
            </trackingData>
          </parcels>
        </deliveries>
      </shippingInfo>
    </order>
    """

  uniqueId = (prefix) ->
    _.uniqueId "#{prefix}#{new Date().getTime()}_"

  shippingMethodMock = (zone, taxCategory) ->
    name: uniqueId 'sm'
    zoneRates: [{
      zone:
        typeId: 'zone'
        id: zone.id
      shippingRates: [{
        price:
          currencyCode: 'EUR'
          centAmount: 99
        }]
      }]
    isDefault: false
    taxCategory:
      typeId: 'tax-category'
      id: taxCategory.id


  zoneMock = ->
    name: uniqueId 'z'

  taxCategoryMock = ->
    name: uniqueId 'tc'
    rates: [{
        name: "5%",
        amount: 0.05,
        includedInPrice: false,
        country: "DE",
        id: "jvzkDxzl"
      }]

  productTypeMock = ->
    name: uniqueId 'pt'
    description: 'bla'

  productMock = (productType) ->
    productType:
      typeId: 'product-type'
      id: productType.id
    name:
      en: uniqueId 'pname'
    slug:
      en: uniqueId 'pslug'
    masterVariant:
      sku: uniqueId 'sku'

  orderMock = (shippingMethod, product, taxCategory) ->
    orderState: 'Open'
    paymentState: 'Pending'
    shipmentState: 'Pending'
    orderNumber: uniqueId 'o-'

    lineItems: [ {
      productId: product.id
      name:
        de: 'foo'
      variant:
        id: 1
      taxRate:
        name: 'myTax'
        amount: 0.10
        includedInPrice: false
        country: 'DE'
      quantity: 1
      price:
        value:
          centAmount: 999
          currencyCode: 'EUR'
    } ]
    totalPrice:
      currencyCode: 'EUR'
      centAmount: 999
    returnInfo: []
    shippingInfo:
      shippingMethodName: 'UPS'
      price:
        currencyCode: 'EUR'
        centAmount: 99
      shippingRate:
        price:
          currencyCode: 'EUR'
          centAmount: 99
      taxRate: _.first taxCategory.rates
      taxCategory:
        typeId: 'tax-category'
        id: taxCategory.id
      shippingMethod:
        typeId: 'shipping-method'
        id: shippingMethod.id
