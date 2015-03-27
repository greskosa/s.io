var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['pixijs', 'Scene', 'text!./../config.json'], function(PIXI, Scene, config) {
  var StartScene;
  config = JSON.parse(config);
  StartScene = (function(_super) {
    __extends(StartScene, _super);

    StartScene.prototype.paused = false;

    function StartScene(screen) {
      StartScene.__super__.constructor.call(this, screen);
      this.addGameTitle();
    }

    StartScene.prototype.updateCallback = function() {};

    StartScene.prototype.addGameTitle = function() {
      console.log(this.size);
      return this.addText(config.appName, {
        font: "56px Verdana",
        fill: "black",
        stroke: "#FF0000",
        strokeThickness: 6
      }, {
        x: this.size.width / 2,
        y: this.size.height / 3
      });
    };

    StartScene.prototype.addSuccesStageUi = function(name, createGameCallback, joinGameCallback, context) {
      this.addPlayerName(name);
      this.addButton('./imgs/creategame.png', './imgs/creategameDown.png', null, {
        x: this.size.width / 2,
        y: this.size.height * 0.62
      }, createGameCallback, context);
      return this.addButton('./imgs/joingame.png', './imgs/joingameDown.png', null, {
        x: this.size.width / 2,
        y: this.size.height * 0.80
      }, joinGameCallback, context);
    };

    StartScene.prototype.addFailedStageUi = function(err, position) {
      return this.addErrorMessage(err, position);
    };

    StartScene.prototype.addErrorMessage = function(msg) {
      return this.addText(msg, {
        font: "28px Verdana",
        fill: "#FF0000",
        stroke: "black",
        strokeThickness: 4
      }, {
        x: this.size.width / 2,
        y: this.size.height * 2 / 3
      });
    };

    StartScene.prototype.addPlayerName = function(name) {
      return this.addText("Your name: " + name, {
        font: "23px Verdana",
        fill: "#FF0000",
        stroke: "black",
        strokeThickness: 2
      }, {
        x: this.size.width * 0.8,
        y: 20
      });
    };

    return StartScene;

  })(Scene);
  return StartScene;
});
