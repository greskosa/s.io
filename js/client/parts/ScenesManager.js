define(['pixijs', 'Scene', 'StartScene', 'CreateGameScene'], function(PIXI, Scene, StartScene, CreateGameScene) {
  var ScenesManager;
  ScenesManager = (function() {
    function ScenesManager() {}

    ScenesManager.prototype.scenes = {};

    ScenesManager.prototype.renderer = null;

    ScenesManager.prototype.currentScene = null;

    ScenesManager.prototype.stage = new PIXI.Stage();

    ScenesManager.prototype.create = function(screen, options) {
      if (this.renderer) {
        return this;
      }
      this.screen = screen;
      this.renderer = PIXI.autoDetectRenderer(screen.width, screen.height, options);
      document.body.appendChild(this.renderer.view);
      requestAnimFrame((function(_this) {
        return function() {
          return _this.loop();
        };
      })(this));
      return this;
    };

    ScenesManager.prototype.loop = function() {
      requestAnimFrame((function(_this) {
        return function() {
          return _this.loop();
        };
      })(this));
      if (!this.currentScene || this.currentScene.isPaused()) {
        return;
      }
      this.currentScene.update();
      return this.renderer.render(this.stage);
    };

    ScenesManager.prototype.createScene = function(id) {
      var scene;
      if (this.scenes[id]) {
        return this.scenes[id];
      }
      switch (id) {
        case 'StartScene':
          scene = new StartScene(this.screen);
          break;
        case 'CreateGameScene':
          scene = new CreateGameScene(this.screen);
          break;
        default:
          scene = new Scene(this.screen);
      }
      this.scenes[id] = scene;
      return scene;
    };

    ScenesManager.prototype.goToScene = function(id) {
      if (!this.scenes[id]) {
        return false;
      }
      if (this.currentScene) {
        this.currentScene.pause();
        this.stage.removeChild(this.currentScene);
      }
      this.currentScene = this.scenes[id];
      this.stage.addChild(this.currentScene);
      this.currentScene.resume(this.renderer.view);
      return true;
    };

    return ScenesManager;

  })();
  return ScenesManager;
});
