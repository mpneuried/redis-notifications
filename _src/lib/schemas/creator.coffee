module.exports = new ( class CreatorSchema extends require( "obj-schema" ) )(
	id: 
		required: true

	firstname: 
		type: "string"

	lastname: 
		type: "string"

	email: 
		type: "email"

, name: "creator" ).validateCb