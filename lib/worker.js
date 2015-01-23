(function() {
  var RNWorker, RSMQWorker,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  RSMQWorker = require("rsmq-worker");

  RNWorker = (function(_super) {
    __extends(RNWorker, _super);

    RNWorker.prototype["default"] = function() {
      return this.extend(RNWorker.__super__["default"].apply(this, arguments), {
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

    function RNWorker(options) {
      this._customExceedCheck = __bind(this._customExceedCheck, this);
      this._start = __bind(this._start, this);
      this["default"] = __bind(this["default"], this);
      RNWorker.__super__.constructor.apply(this, arguments);
      this.worker = new RSMQWorker(this.config.queuename, {
        interval: this.config.interval,
        customExceedCheck: this._customExceedCheck,
        redis: this.config.client,
        redisPrefix: this.config.prefix,
        host: this.config.host,
        port: this.config.port,
        options: this.config.options
      });
      this.start();
      this.start = this._waitUntil(this._start, "ready", this.worker);
      return;
    }

    RNWorker.prototype._start = function() {
      this.debug("START");
    };

    RNWorker.prototype._customExceedCheck = function(msg) {
      if (msg.message === "check") {
        return true;
      }
      return false;
    };

    return RNWorker;

  })(require("mpbasic")());

  module.exports = new RNWorker();

}).call(this);
