define([
    'pixijs','Scene','StartScene','CreateGameScene','JoinGameScene'
],  (PIXI,Scene,StartScene,CreateGameScene,JoinGameScene)->

  class ScenesManager
    scenes:{}
    renderer:null
    currentScene:null
    stage:new PIXI.Stage()

    #     /**
    #     * Create an instance of Renderer
    #     *
    #     * @param {object} screen Width,Height or Scale of canvas.
    #     * @param {object} options Options of renderer, fox example transparent.
    #     */
    create: (screen,options)->
      if (@renderer) then return @
      @screen=screen
      @renderer= PIXI.autoDetectRenderer(screen.width, screen.height, options);
      document.body.appendChild(@renderer.view);
      requestAnimFrame(()=>@loop());
      return @;

    #    /**
    #    * Rerender current scene via requestAnimFrame
    #    *
    #    */
    loop:()->
      requestAnimFrame(()=>@loop());
      if (!@currentScene || @currentScene.isPaused()) then return;
      @currentScene.update();
#      console.log(@currentScene)
      @renderer.render(@stage);

    #    /**
    #    * Create new scene
    #    *
    #    * @param {string} id Id of new scene.
    #    */
    createScene:(id)->
      if (@scenes[id])
        return @scenes[id]; #//doesn't create if exist, just return
      switch id
        when 'StartScene' then  scene = new StartScene(@screen);
        when 'CreateGameScene' then scene = new CreateGameScene(@screen);
        when 'JoinGameScene' then scene = new JoinGameScene(@screen);
        else
          scene=new Scene(@screen)
      @scenes[id] = scene;
      return scene;

    #    /**
    #     * Change current scene
    #     *
    #     * @param {string} id Id of new scene.
    #     */
    goToScene:(id)->
      if(!@scenes[id]) then return false;
      if(@currentScene)
        @currentScene.pause()
        @stage.removeChild(@currentScene)
      @currentScene= @scenes[id]
      @stage.addChild(@currentScene)
      @currentScene.resume(@renderer.view)
      return true

  return ScenesManager
)

