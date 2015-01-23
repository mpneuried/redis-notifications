(function() {
  var RedisNotifications, Worker,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Worker = require("./worker");

  RedisNotifications = (function(_super) {
    __extends(RedisNotifications, _super);

    RedisNotifications.prototype["default"] = function() {
      return this.extend(RedisNotifications.__super__["default"].apply(this, arguments), {
        queuename: "notifications",
        interval: [0, 1, 5, 10],
        host: "localhost",
        port: 6379,
        options: {},
        client: null,
        prefix: "notifications"
      });
    };


    /*	
    	 *# constructor
     */

    function RedisNotifications(options) {
      this._start = __bind(this._start, this);
      this["default"] = __bind(this["default"], this);
      RedisNotifications.__super__.constructor.apply(this, arguments);
      this.worker = new RSMQWorker(this.config.queuename, this.config);
      this.start();
      this.start = this._waitUntil(this._start, "connected");
      return;
    }

    RedisNotifications.prototype._start = function() {
      this.worker.on("message", this);
      this.debug("START");
    };

    return RedisNotifications;

  })(require("mpbasic")());

  module.exports = RedisNotifications;

}).call(this);
