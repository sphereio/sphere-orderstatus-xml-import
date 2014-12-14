_ = require 'underscore'
xml2js = require 'xml2js'

exports.xmlFix = (xml) ->
  if not xml.match /\?xml/
    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>#{xml}"
  xml

exports.xmlTransform = (xml, callback) =>
  parser = new xml2js.Parser({explicitArray: false})
  parser.parseString xml, callback
