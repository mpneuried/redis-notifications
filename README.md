
![redis-notifications](https://trello-attachments.s3.amazonaws.com/5481963992d9ba3848568a1b/600x199/0942ef2e9e86200b258685b0ff02f794/redis-notifications_pxl.png)

[![Build Status](https://secure.travis-ci.org/mpneuried/redis-notifications.png?branch=master)](http://travis-ci.org/mpneuried/redis-notifications)
[![Build Status](https://david-dm.org/mpneuried/redis-notifications.png)](https://david-dm.org/mpneuried/redis-notifications)
[![NPM version](https://badge.fury.io/js/redis-notifications.png)](http://badge.fury.io/js/redis-notifications)

A redis based notification engine.
It implements the [**rsmq-worker**](https://github.com/mpneuried/rsmq-worker) to safely create notifications and recurring reports.

The goal is to define a simple API to be able to send notifications and mails to multiple users.
A user can define a setting to only receive one mail per day as a report.
This is all done within a queuing solution. so it's scalable and failsafe.

[![NPM](https://nodei.co/npm/redis-notifications.png?downloads=true&stars=true)](https://nodei.co/npm/redis-notifications/)


## Install

```sh
  npm install redis-notifications
```

## Initialize


**initialize**

```js
    var RedisNotifications = require( "redis-notifications" );

    var nf = new RedisNotifications();

    // REQUIRED EVENT LISTENERS
    // listen to errors
    nf.on( "error", function( err ){});

    // Hock to read details of an user
    nf.on( "readUser", function( user_id, cb ){ /* ... */ });

    // Hook to generate the message content for the notification and the mail
    nf.on( "getContent", function( type, user, editor, additional, cb ){  /* ... */ });

    // Hook to write/send the notification to the user. Is is done immediately on every create
    nf.on( "createNotification", function( user, editor, message, cb ){ /* ... */ });

    // Hook to send a report to a user.
    nf.on( "sendMail", function( user, messages, isReport, cb ){ /* ... */ });

    // INIT
    nf.init();

    // METHODS
    // define the data of the editor
    var editor = { id: "ABCDE", firstname: "William", lastname: "Creator", email: "william.create@example.com" };

    // create a notification to a single user
    nf.create( editor, { type: "notification_type", user: 123 }, function( err, msgid ){  /* ... */  });
```

**Config** 

- **options** *( `Object` optional )* The configuration object
	- **options.maxBufferReadCount**: *( `Number` optional; default = `100` )* Count of users to read at once to send mails
	
	**[RSMQ-Worker Options](https://github.com/mpneuried/rsmq-worker#initialize)**
	
	- **options.queuename**: *( `String` optional; default = `rnqueue` )* The queuename to pull the messages
	- **options.interval**: *( `Number[]` optional; default = `[ 0, 1, 5, 10 ]` )* An Array of increasing wait times in seconds
	- **options.maxReceiveCount**: *( `Number` optional; default = `10` )* Receive count until a message will be exceeded
	- **options.invisibletime**: *( `Number` optional; default = `30` )* A time in seconds to hide a message after it has been received.
	- **options.defaultDelay**: *( `Number` optional; default = `1` )* The default delay in seconds for for sending new messages to the queue.
	- **options.timeout**: *( `Number` optional; default = `3000` )* Message processing timeout in `ms`. So you have to call the `next()` method of `message` at least after e.g. 3000ms. If set to `0` it'll wait until infinity.
	- **options.prefix**: *( `String` optional; default = `notifications` )* The redis namespace for rsmq
	- **options.client**: *( `RedisClient` optional; default = `null` )* A already existing redis client instance to use.
	- **options.host**: *( `String` optional; default = `localhost` )* Host to connect to redis if `redis` instance has been defined 
	- **options.port**: *( `Number` optional; default = `6379` )* Port to connect to redis if `redis` instance has been defined 
	- **options.options**: *( `Object` optional; default = `{}` )* Options to connect to redis if `redis` instance has been defined 

## Event Hooks

### `readUser`

Call to read a user by the given id. So you have to implement the DB/API read yourself

**Arguments** 

- **user_id** : *( `String|Number` )* The user id to read
- **cb** : *( `Function` )* The callback function
	
	**Callback Params:**
	
	- **err** : *( `Null|Error` )* An optional error
	- **user** : *( `Object` )* The user result with the following fields. You can also add additional fields you need later
		- **user.id** : *( `String|Number`, required )* The user_id
		- **user.firstname** : *( `String`, required )* The user's first name. 
		- **user.lastname** : *( `String`, optional )* The user's last name. 
		- **user.email** : *( `String`, required )* The user's email. 
		- **user.timezone** : *( `String`, required )* A timezone string. It has to be a valid [moment timezone](http://momentjs.com/timezone/) string
		- **user.sendInterval** : *( `String`, required )* The send interval. This defines if, how and when the user will receive a email
	
			**Possible values:**
	
			- **`0`:** The user will never receive a mail
			- **`p`:** receive the only prio mails *( created with `high:true` )* immediately
			- **`i`:** receive the mail immediately
			- **`d{time}`:** receive the mail daily report. The time has to be a 4 digit number. E.g. `0800` = 8 in the morning within his timezone. `2330` = half an hour before midnight.

### `getContent`

Create the notification content

**Arguments** 

- **type** : *( `String` )* The message type you defined on `.create{Multile}()`
- **user** : *( `Object` )* User result generated by you within the `readUser` hook
- **editor** : *( `Object` )* User editor you added on `.create{Multile}()`
- **additional** : *( `Object` )* User additional data you added on `.create{Multile}()`
- **cb** : *( `Function` )* The callback function
	
	**Callback Params:**
	
	- **err** : *( `Null|Error` )* An optional error
	- **content** : *( `Object` )* The content result with the following fields. You can also add additional fields you need later
		- **content.subject** : *( `String`, required )* The message subject/headline
		- **content.body** : *( `String`, required )* The message body
		- **content.teaser** : *( `String`, optional )* The message teaser. HTML will be stripped out! If not defined the module truncates the `body` to 100 chars. 

### `createNotification`

This will called immediately after `.create{Multile}()`.
Here you have to write the notification to your db and/or send it immediately to the user.

**Arguments** 

- **user** : *( `Object` )* User result generated by you within the `readUser` hook
- **editor** : *( `Object` )* User editor you added on `.create{Multile}()`
- **message** : *( `Object` )* The message content you created within the `getContent` hook
- **cb** : *( `Function` )* The callback function
	
	**Callback Params:**
	
	- **err** : *( `Null|Error` )* An optional error

### `sendMail`

Send a mail to the user.
This is only done if `sendInterval` is `d{time}`, `i` or `p`
Only on `d{time}` a report is generated witch could contain more than one message.

**Arguments** 

- **user** : *( `Object` )* User result generated by you within the `readUser` hook
- **messages** : *( `Object[]` )* An Array messages you created within the `getContent` hooks
- **isReport** : *( `Boolean` )* A flag that tells you this mail is a report because the user used `sendInterval = "d{time}"`.
- **cb** : *( `Function` )* The callback function
	
	**Callback Params:**
	
	- **err** : *( `Null|Error` )* An optional error

### `error`

An error occurred

**Arguments** 

- **err** : *( `Error` )* A error

## Methods

### `.init()`

After you added the required hooks you have the call `.init()` to start the module.

### `.create( editor, message [, cb ] )`

Create a notification for one user

**Arguments**

* `editor` : *( `Object` required )*: The sending editor
	* `editor.id` : *( `String|Number` required )*: a unique identifier of the notification creator
	* `editor.firstname` : *( `String` optional )*: The first name of the creator
	* `editor.lastname` : *( `String` optional )*: The last name of the creator
	* `editor.email` : *( `String` optional )*: The email of the creator
* `message` : *( `Object` required )*: The message data
	* `message.type` : *( `String` required )*: The notification type. This is a key to be able to generate different notification contents
	* `message.user` : *( `String|Number` required )*: The id of the user that will receive this message
	* `message.high` : *( `Boolean` optional; default = `false` )*: This flag marks this notification as high prio. So mails will send immediately and users with `sendInterval = "p"` will alos get a mail.
	* `message.additional` : *( `Object` optional )*: An object you could use to place custom data. This cwill be passed to the hook `getContent`
* `cb` : *( `Function` optional )*: A optional callback method. Callback arguments: `function( err, nid ){}`

**Return**

*( Null|Error )*: Null on success or a validation error.

### `.createMulti( editor, message [, cb ] )`

Create a notification for multiple users

**Arguments**

* `editor` : *( `Object` required )*: The sending editor
	* `editor.id` : *( `String|Number` required )*: a unique identifier of the notification creator
	* `editor.firstname` : *( `String` optional )*: The first name of the creator
	* `editor.lastname` : *( `String` optional )*: The last name of the creator
	* `editor.email` : *( `String` optional )*: The email of the creatore
* `message` : *( `Object` required )*: The message data
	* `message.type` : *( `String` required )*: The notification type. This is a key to be able to generate different notification contents
	* `message.users` : *( `Array` required )*: An Array of user ids that will receive this notification.
	* `message.high` : *( `Boolean` optional; default = `false` )*: This flag marks this notification as high prio. So mails will send immediately and users with `sendInterval = "p"` will alos get a mail.
	* `message.additional` : *( `Object` optional; default = `{}` )*: An object you could use to place custom data. This will be passed to the hook `getContent`
* `cb` : *( `Function` optional )*: A optional callback method. Callback arguments: `function( err ){}`

**Return**

*( Null|Error )*: Null on success or a validation error.

### `.getRsmqWorker()`

Helper method to get internal used instance

**Return**

*( RSMQWorker )*: The internal [rsmq-worker](https://github.com/mpneuried/rsmq-worker) instance.

### `.getRsmq()`

Helper method to get internal used instance

**Return**

*( RedisSMQ )*: The internal [rsmq](https://github.com/smrchy/rsmq) instance.

### `.getRedis()`

Helper method to get internal used instance

**Return**

*( RedisClient )*: The internal [redis](https://github.com/mranney/node_redis) instance.

## Example

This is a example implementation.
It's up to you to implement the DB read and Write methods and do the notification and mail sending.

```js
    var RedisNotifications = require( "redis-notifications" );

    var nf = new RedisNotifications();

    // REQUIRED EVENT LISTENERS
    // listen to errors
    nf.on( "error", function( err ){
        console.error( err, err.stack );
    });

    // Hock to read details of an user
    nf.on( "readUser", function( user_id, cb ){

        // here you have to query your database and return a valid user with at least these fields
        var user = {
            // required fields
            id: user_id,                                // unique user id
            firstname: "John",          
            email: "john.do@mail.com",
            timezone: "CET",                        // a moment-timezone valid timezone
            sendInterval: "i",                      // when to send a mail 

            // optional fields
            lastname: "Do",             

            // custom fields
            custom_lang: "DE"                       // it is possible to add custom fields
        };
        cb( null, user );
    });

    // Hook to generate the message content for the notification and the mail
    nf.on( "getContent", function( type, user, editor, additional, cb ){

        // here you have to generate your message by type. Usually you would use a template-engine
        
        var content = {
            // required fields
            subject: "This is my message subject",
            body: "Lorem ipsum dolor ...",          

            // custom fields
            custom_field: additional.custom_key,    // it is possible to add custom fields to the content
            custom_lang: user.custom_lang           // reuse the custom field from user
        };
        cb( null, content );
    });

    // Hook to write/send the notification to the user. Is is done immediately on every create
    nf.on( "createNotification", function( user, editor, message, cb ){

        // here you have to write the notification to your db and/or send it immediately to the user

        cb( null );
    });

    // Hook to send a report to a user.
    // This is only done if `sendInterval` is `d{time}`, `i` or `p`
    // Only on `d{time}` a report is generated witch could contain more than one message
    nf.on( "sendMail", function( user, messages, isReport, cb ){

        // here you have to do create of the mail content and mail send it.

        cb( null );
    });

    // INIT
    // you have to initialize the module until the required listeners has been added
    nf.init();

    // METHODS

    // define the data of the editor
    var editor = {
        // required fields
        id: "ABCDE",

        // optional fields
        firstname: "William",
        lastname: "Creator",
        email: "william.create@example.com",

        // custom fields
        custom_lang: "DE"
    };


    // create a notification for multiple users without callback
    var errCrM = nf.createMulti( editor, {
        type: "notification_type",                  // A type to differ the content in the `getContent` hook
        users: [ 123, 456, 789 ],                   // An array of user that will receive this notification
        high: true                                  // A flag to define this notification as high prio.
    });
    if( errCrM ){
        console.error( errCrM );
    }
    // High means:
    // - This message will be send by mail immediately.
    // - Users with `sendInterval = "p"` (only high prio) will also get this notification.

    // create a notification to a single user
    nf.create( editor, {
        type: "notification_type",                  // A type to differ the content in the `getContent` hook
        user: 123,                                  // The user id that will receive this notification
        high: false,                                // A flag to define this notification as high prio.
        additional: {
            custom_icon: "info"                     // additional data that later can be used with in the `getContent` hook
        }
    }, function( err, msgid ){
        if( err ){
            console.error( err );
        }
    });
```

## Todos

- Tests
- add `sendInterval` variant to send the report weekly and/or monthly.

## Release History
|Version|Date|Description|
|:--:|:--:|:--|
|0.2.1|2016-10-27|Small bugfix with default value (Thanks to [Anton Rau](https://github.com/plankter) for [#3](https://github.com/mpneuried/redis-notifications/issues/3)). Updated dependencies|
|0.2.0|2016-07-18|Updated dev env and dependencies|
|0.1.1|2015-01-30|Logo update|
|0.1.0|2015-01-30|Added docs and optimized code and API|
|0.0.2|2015-01-29|moved schema to extra module `obj-schema`|
|0.0.1|2015-01-29|Initial version. No tests and docs until now!|

[![NPM](https://nodei.co/npm-dl/redis-notifications.png?months=6)](https://nodei.co/npm/redis-notifications/)

> Initially Generated with [generator-mpnodemodule](https://github.com/mpneuried/generator-mpnodemodule)

## Other projects

|Name|Description|
|:--|:--|
|[**rsmq**](https://github.com/smrchy/rsmq)|A really simple message queue based on Redis|
|[**rsmq-worker**](https://github.com/mpneuried/rsmq-worker)|Helper to simply implement a worker [RSMQ ( Redis Simple Message Queue )](https://github.com/smrchy/rsmq).|
|[**node-cache**](https://github.com/tcs-de/nodecache)|Simple and fast NodeJS internal caching. Node internal in memory cache like memcached.|
|[**obj-schema**](https://github.com/mpneuried/obj-schema)|Simple module to validate an object by a predefined schema|
|[**redis-sessions**](https://github.com/smrchy/redis-sessions)|An advanced session store for NodeJS and Redis|
|[**connect-redis-sessions**](https://github.com/mpneuried/connect-redis-sessions)|A connect or express middleware to simply use the [redis sessions](https://github.com/smrchy/redis-sessions). With [redis sessions](https://github.com/smrchy/redis-sessions) you can handle multiple sessions per user_id.|
|[**systemhealth**](https://github.com/mpneuried/systemhealth)|Node module to run simple custom checks for your machine or it's connections. It will use [redis-heartbeat](https://github.com/mpneuried/redis-heartbeat) to send the current state to redis.|
|[**task-queue-worker**](https://github.com/smrchy/task-queue-worker)|A powerful tool for background processing of tasks that are run by making standard http requests.|
|[**soyer**](https://github.com/mpneuried/soyer)|Soyer is small lib for serverside use of Google Closure Templates with node.js.|
|[**grunt-soy-compile**](https://github.com/mpneuried/grunt-soy-compile)|Compile Goggle Closure Templates ( SOY ) templates inclding the handling of XLIFF language files.|
|[**backlunr**](https://github.com/mpneuried/backlunr)|A solution to bring Backbone Collections together with the browser fulltext search engine Lunr.js|


## The MIT License (MIT)

Copyright © 2015 Mathias Peter, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
