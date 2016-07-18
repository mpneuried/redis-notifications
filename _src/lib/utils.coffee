# # Utils
#
# ### Exports: *Object*
# 
# A collection of helper functions

# export the functions
module.exports =
	###
	## randomString
	
	`utils.randomString( string_length, speciallevel )`
	
	Generate a random string
	
	@param { Number } string_length string length to generate 
	@param { Number } speciallevel Level of complexity.
		* 0 = only letters upper and lowercase, 52 possible chars;
		* 1 = 0 + Numbers, 62 possible chars;
		* 2 = 1 + "_-@:.", 67 possible chars;
		* 3 = 2 + may speacial chars, 135 possible chars;
	
	@return { String } The gerated string 
	###
	randomString: ( string_length = 5, specialLevel = 0 ) ->
		chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
		chars += "0123456789" if specialLevel >= 1
		chars += "_-@:." if specialLevel >= 2
		chars += "!\"§$%&/()=?*'_:;,.-#+¬”#£ﬁ^\\˜·¯˙˚«∑€®†Ω¨⁄øπ•‘æœ@∆ºª©ƒ∂‚å–…∞µ~∫√ç≈¥" if specialLevel >= 3

		randomstring = ""
		i = 0
		
		while i < string_length
			rnum = Math.floor(Math.random() * chars.length)
			randomstring += chars.substring(rnum, rnum + 1)
			i++
		randomstring

	###
	## randRange
	
	`utils.randRange( lowVal, highVal )`
	
	Create a random number bewtween two values
	
	@param { Number } lowVal Min number 
	@param { Number } highVal Max number 
	
	@return { Number } A random number 
	###
	randRange: randRange = ( lowVal, highVal )->
		return Math.floor( Math.random()*(highVal-lowVal+1 ))+lowVal

	###
	## randPick
	
	`utils.randPick( lowVal, highVal )`
	
	creates a function that picks a random element out of the given array
	
	@param { Number } arr The array of values to pick out
	
	@return { Function } A Function that returns a ranom value out of the given array
	###
	randPick: ( arr )->
		_l = arr.length - 1
		return ->
			return arr[ randRange( 0, _l ) ]

	###
	## lpad
	
	`utils.lpad( lowVal, highVal )`
	
	Left pad string
	
	@param { String } value The value to pad
	@param { Number } [padding=2] The padding size
	@param { String } [fill="0"] The filler value.
	
	@return { String } the padded value
	###
	lpad: (value, padding = 2, fill = "0") ->
		fill += fill for i in [1..padding]
		return (fill + value).slice(padding * -1)

	###
	## truncate
	
	`utils.truncate( str [, len] [, tolerance] )`
	
	Truncate a string to the given `len` of chars and cut at the nearest following space.
	
	@param { String } value The string to truncate
	@param { Number } [len=100] The char count
	@param { String } [tolerance=5] The tolerance in percent to not truncate a string if it's length exceeds up to x%.
	
	@return { String } the truncated string
	###
	truncate: ( str, len = 100, add = "...", tolerance = 5 )->
		if str.length > ( len * ( 1 + tolerance/100 ) )
			return str.substr( 0, str.indexOf( " ", len ) ) + ( add or "" )
		return str
