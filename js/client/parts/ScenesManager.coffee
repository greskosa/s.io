define([
    'pixijs','Scene','StartScene','CreateGameScene','JoinGameScene','GameScene','text!./../config.json'
],  (PIXI,Scene,StartScene,CreateGameScene,JoinGameScene,GameScene,config)->
  config=JSON.parse(config)
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
    create: (options,isScale)->
      if (@renderer) then return @
      @renderer= new PIXI.CanvasRenderer(config.originalWidth, config.originalHeight, options);
      document.body.appendChild(@renderer.view);
      @renderer.view.style.opacity=1
      if (isScale)
        @rescale();
        window.addEventListener('resize', ()=>
          @rescale()
        , false);
      requestAnimFrame(()=>@loop());
      return @;


    rescale:()->
      console.log('rescale')
      @ratio = Math.min(window.innerWidth / config.originalWidth, window.innerHeight / config.originalHeight)
      @width = config.originalWidth * @ratio;
      @height =  config.originalHeight * @ratio;
      @renderer.resize(@width, @height);
      console.log( @renderer.view.style)
      @renderer.view.style.marginLeft=-@width/2+"px"
      @renderer.view.style.marginTop=-@height/2+"px"
      console.log(@renderer)


    #    /**
    #    * Rerender current scene via requestAnimFrame
    #    *
    #    */
    loop:()->
      requestAnimFrame(()=>@loop());
      if (!@currentScene || @currentScene.isPaused()) then return;
      @currentScene.update();
      @applyRatio(@currentScene, @ratio); #//scale to screen size
      @renderer.render(@stage);
      @applyRatio(@currentScene, 1/@ratio); #//restore original scale

    applyRatio:(displayObject, ratio)->
      if (ratio == 1) then return;
#      console.log(ratio)
#      console.log(displayObject.position)
#      console.log(displayObject.scale)
      displayObject.position.x = displayObject.position.x * ratio;
      displayObject.position.y = displayObject.position.y * ratio;
      displayObject.scale.x = displayObject.scale.x * ratio;
      displayObject.scale.y = displayObject.scale.y * ratio;
#      if displayObject.children&&displayObject.children.length
#        displayObject.children.forEach((child)=>
#          @applyRatio(child, ratio);
#        )

    #    /**
    #    * Create new scene
    #    *
    #    * @param {string} id Id of new scene.
    #    */
    createScene:(id)->
      if (@scenes[id])
        return @scenes[id]; #//doesn't create if exist, just return
      switch id
        when 'StartScene' then  scene = new StartScene();
        when 'CreateGameScene' then scene = new CreateGameScene();
        when 'JoinGameScene' then scene = new JoinGameScene();
        when 'GameScene' then scene = new GameScene();
        else
          scene=new Scene()
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

