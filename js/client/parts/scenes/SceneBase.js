var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['pixijs'], function(PIXI) {
  var Scene;
  Scene = (function(_super) {
    __extends(Scene, _super);

    Scene.prototype.updateCallback = null;

    Scene.prototype.pausedCustom = false;

    Scene.prototype.size = {
      width: 0,
      height: 0
    };

    Scene.prototype.scale = {
      scaleX: 1,
      scaleY: 1
    };

    function Scene(screen) {
      Scene.__super__.constructor.call(this);
      if (screen) {
        this.setCanvasSize(screen.width, screen.height);
        this.setScale(screen.scaleX, screen.scaleY);
      }
    }

    Scene.prototype.setCanvasSize = function(width, height) {
      this.size.width = width;
      return this.size.height = height;
    };

    Scene.prototype.setScale = function(scaleX, scaleY) {
      this.scale.scaleX = scaleX;
      return this.scale.scaleY = scaleY;
    };

    Scene.prototype.onUpdate = function(updateCallback) {
      if (!updateCallback) {
        return false;
      }
      this.updateCallback = updateCallback;
      return true;
    };

    Scene.prototype.update = function() {
      if (this.updateCallback) {
        return this.updateCallback();
      }
    };

    Scene.prototype.pause = function() {
      this.pausedCustom = true;
      return this.visible = false;
    };

    Scene.prototype.resume = function(view) {
      console.log(view);
      this.pausedCustom = false;
      return this.visible = true;
    };

    Scene.prototype.isPaused = function() {
      return this.pausedCustom;
    };

    Scene.prototype.addText = function(text, options, position) {
      text = new PIXI.Text(text, options);
      text.position.x = position.x;
      text.position.y = position.y;
      text.anchor.x = 0.5;
      text.anchor.y = 0.5;
      text.scale.x = this.scale.scaleX;
      text.scale.y = this.scale.scaleY + 0.1;
      this.addChild.call(this, text);
      return text;
    };

    Scene.prototype.addTransparentBg = function() {
      var bg;
      bg = PIXI.Sprite.fromImage("imgs/transparent-bg.png");
      bg.position.x = 0;
      bg.position.y = 0;
      return this.addChild.call(this, bg);
    };

    Scene.prototype.addButton = function(imgDefault, imgDown, imgOver, position, callback, context) {
      var button, self, textureButton, textureButtonDown;
      self = this;
      textureButton = PIXI.Texture.fromImage(imgDefault);
      textureButtonDown = PIXI.Texture.fromImage(imgDown);
      button = new PIXI.Sprite(textureButton);
      button.buttonMode = true;
      button.interactive = true;
      button.anchor.x = 0.5;
      button.anchor.y = 0.5;
      button.scale.x = this.scale.scaleX;
      button.scale.y = this.scale.scaleY;
      button.position.x = position.x;
      button.position.y = position.y;
      button.mousedown = button.touchstart = function(data) {
        if (self.isPaused()) {
          return;
        }
        console.log('111');
        return this.setTexture(textureButtonDown);
      };
      button.mouseup = button.touchend = function(data) {
        if (self.isPaused()) {
          return;
        }
        console.log('222');
        return this.setTexture(textureButton);
      };
      button.click = button.tap = function(data) {
        if (self.isPaused()) {
          return;
        }
        if (callback) {
          return callback.call(context);
        }
      };
      this.addChild(button);
      return this.interactive = true;
    };

    return Scene;

  })(PIXI.DisplayObjectContainer);
  return Scene;
});
