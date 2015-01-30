# [utils](./utils.coffee.html)
utils = require( "../utils" ) 

module.exports = new ( class MessageContentSchema extends require( "obj-schema" ) )(
	subject: 
		type: "string"
		required: true

	body: 
		type: "string"
		required: true
		sanitize: true

	teaser: 
		type: "string"
		sanitize: true
		striphtml: true
		default: ( data, def )->
			return utils.truncate( data.body, 100 )

, name: "messagecontent" ).validateCb