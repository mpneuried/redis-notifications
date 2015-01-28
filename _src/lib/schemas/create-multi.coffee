module.exports = new ( class CreateMutliSchema extends require( "./schema" ) )(
	type: 
		type: "string"
		required: true

	users: 
		type: "array"
		required: true

	high: 
		type: "boolean"
		default: false

	additional: 
		type: "object"
		default: {}

, name: "createmulti" ).validateCb