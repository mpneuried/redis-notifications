module.exports = new ( class CreateSchema extends require( "./schema" ) )(
	type: 
		type: "string"
		required: true

	user: 
		required: true

	high: 
		type: "boolean"
		default: false

	additional: 
		type: "object"
		default: {}

, name: "create" ).validateCb