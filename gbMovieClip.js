// Generated by CoffeeScript 1.10.0

/**
 * Create by gitbong
 * github:gitbong
 */

(function() {
  var MovieClip, Timeline,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Timeline = (function() {
    Timeline.prototype._totalFrame = 0;

    Timeline.prototype._framerate = 30;

    Timeline.prototype._currframe = 1;

    Timeline.prototype._targetframe = 1;

    Timeline.prototype._timer = -1;

    Timeline.prototype._playType = 1;

    Timeline.prototype._evtMap = {};

    Timeline.prototype.loop = false;

    function Timeline(totalFrame, framerate) {
      if (framerate == null) {
        framerate = 30;
      }
      this._totalFrame = totalFrame;
      this._framerate = 1000 / framerate;
      this._evtMap = {};
      this.__defineGetter__('totalFrame', function() {
        return this._totalFrame;
      });
      this.__defineSetter__('totalFrame', function() {
        throw "totalFrame read only";
      });
      this.__defineGetter__('currentFrame', function() {
        return this._currframe;
      });
      this.__defineSetter__('currentFrame', function() {
        throw "currentFrame read only";
      });
      this._render(1);
    }

    Timeline.prototype.on = function(evt, fn) {
      if (this._evtMap[evt] === void 0) {
        this._evtMap[evt] = [];
      }
      return this._evtMap[evt].push(fn);
    };

    Timeline.prototype._trigger = function(evt) {
      var arr, i, j, len, results;
      arr = this._evtMap[evt];
      if (arr === void 0) {
        arr = [];
      }
      results = [];
      for (j = 0, len = arr.length; j < len; j++) {
        i = arr[j];
        if (typeof i === "function") {
          results.push(i({
            currFrame: this.currentFrame,
            totalFrame: this.totalFrame
          }));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    Timeline.prototype.nextFrame = function() {
      this._currframe++;
      if (this._currframe === this._totalFrame + 1 && this.loop === true) {
        console.log(1);
        this._currframe = 1;
      } else {
        this._currframe = this._frame(this._currframe);
      }
      this._trigger('playing');
      return this._render(this._currframe);
    };

    Timeline.prototype.prevFrame = function() {
      this._currframe--;
      this._currframe = this._frame(this._currframe);
      this._trigger('playing');
      return this._render(this._currframe);
    };

    Timeline.prototype.play = function() {
      var _this;
      _this = this;
      this._playType = 1;
      this.stop();
      this._targetframe = this._totalFrame;
      return this._timer = setTimeout(function() {
        _this.play();
        return _this.nextFrame();
      }, this._framerate);
    };

    Timeline.prototype.playTo = function(frame) {
      var _this;
      _this = this;
      this._playType = 2;
      this.stop();
      this._targetframe = this._frame(frame);
      return this._timer = setTimeout(function() {
        _this.playTo(frame);
        if (_this._targetframe < _this._currframe) {
          return _this.prevFrame();
        } else if (_this._targetframe > _this._currframe) {
          return _this.nextFrame();
        }
      }, this._framerate);
    };

    Timeline.prototype.stop = function() {
      return clearTimeout(this._timer);
    };

    Timeline.prototype.gotoAndPlay = function(frame) {
      this._currframe = this._frame(frame);
      this._render(this._currframe);
      this.stop();
      return this.play();
    };

    Timeline.prototype.gotoAndStop = function(frame) {
      this._currframe = this._frame(frame);
      this._render(this._currframe);
      return this.stop();
    };

    Timeline.prototype._frame = function(frame) {
      if (frame > this.totalFrame) {
        frame = this.totalFrame;
      }
      if (frame < 1) {
        frame = 1;
      }
      return frame;
    };

    Timeline.prototype._render = function(frame) {
      if (this.loop) {
        if (frame === this._totalFrame && this._playType === 1) {
          return this._currframe = 0;
        }
      } else {
        if (frame === this._targetframe) {
          return this.stop();
        }
      }
    };

    return Timeline;

  })();

  MovieClip = (function(superClass) {
    extend(MovieClip, superClass);

    MovieClip.prototype._dom = -1;

    MovieClip.prototype._ctx = -1;

    MovieClip.prototype._imgs = [];

    function MovieClip(libs1, width, height, framerate, initedFn) {
      this.libs = libs1;
      this.width = width;
      this.height = height;
      if (framerate == null) {
        framerate = 30;
      }
      this.initedFn = initedFn;
      MovieClip.__super__.constructor.call(this, libs.length, framerate);
      this._dom = document.createElement('canvas');
      this._dom['width'] = this.width;
      this._dom['height'] = this.height;
      this._ctx = this._dom.getContext('2d');
      this.__defineGetter__('dom', function() {
        return this._dom;
      });
      this._loadLibs();
    }

    MovieClip.prototype._loadLibs = function() {
      var _this, id;
      _this = this;
      id = this._imgs.length;
      if (id === this.libs.length) {
        this._render(1);
        if (typeof this.initedFn === "function") {
          return this.initedFn();
        }
      } else {
        return this._loadImg(this.libs[id], function(img) {
          _this._imgs.push(img);
          return _this._loadLibs();
        });
      }
    };

    MovieClip.prototype._loadImg = function(url, fn) {
      var img;
      img = new Image;
      img.onload = function() {
        if (typeof fn === "function") {
          return fn(img);
        }
      };
      return img.src = url;
    };

    MovieClip.prototype._render = function(frame) {
      if (this._ctx.drawImage) {
        this._ctx.drawImage(this._imgs[frame - 1], 0, 0, this.width, this.height);
      }
      return MovieClip.__super__._render.call(this, frame);
    };

    return MovieClip;

  })(Timeline);

  window.gbTimeline = Timeline;

  window.gbMovieClip = MovieClip;

}).call(this);

//# sourceMappingURL=gbMovieClip.js.map