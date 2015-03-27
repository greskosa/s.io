var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['pixijs', 'Scene', 'text!./../config.json'], function(PIXI, Scene, config) {
  var CreateGameScene;
  config = JSON.parse(config);
  CreateGameScene = (function(_super) {
    __extends(CreateGameScene, _super);

    function CreateGameScene(screen) {
      CreateGameScene.__super__.constructor.call(this, screen);
      this.click = this.tap = function(data) {
        return console.log('3333');
      };
    }

    CreateGameScene.prototype.loadingWait = function() {
      var textMessage;
      textMessage = 'Loading. Please wait...';
      if (!this.text) {
        return this.text = this.addText(textMessage, {
          font: "40px Verdana",
          fill: "black",
          stroke: "#FF0000",
          strokeThickness: 6
        }, {
          x: this.size.width / 2,
          y: this.size.height / 2
        });
      } else {
        return this.text.setText(textMessage);
      }
    };

    CreateGameScene.prototype.changeText = function(text) {
      if (this.text) {
        return this.text.setText(text);
      }
    };

    return CreateGameScene;

  })(Scene);
  return CreateGameScene;
});
