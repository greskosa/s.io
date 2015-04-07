define([
    'pixijs'
],  (PIXI)->
   class Scene extends PIXI.DisplayObjectContainer
      updateCallback:null
      pausedCustom:false
      size:
        width:0,
        height:0

      scale:
        scaleX:1
        scaleY:1

      constructor:(screen)->
        super()
        if screen
          @setCanvasSize(screen.width,screen.height)
          @setScale(screen.scaleX,screen.scaleY)

      setCanvasSize:(width,height)->
          @size.width=width
          @size.height=height

      setScale:(scaleX,scaleY)->
          @scale.scaleX=scaleX
          @scale.scaleY=scaleY

      onUpdate:(updateCallback)->
          if(!updateCallback) then return false
          @updateCallback=updateCallback
          return true;

      update:()->
          if(@updateCallback) then @updateCallback()

      pause:()->
          @pausedCustom = true;
          @visible = false;

      resume:(view)->
        console.log(view)
        @pausedCustom = false;
        @visible = true;
#        @interactionManager.setTargetDomElement(view)


      isPaused:()->
          return @pausedCustom;

      addText:(text,options,position,callback)->
          text = new PIXI.Text(text, options);
          text.position.x=position.x;
          text.position.y=position.y;
#          // center the sprites anchor point
          text.anchor.x = 0.5;
          text.anchor.y = 0.5;
          text.scale.x = @scale.scaleX
          text.scale.y = @scale.scaleY+0.1 #//#hard fix
          if callback
            text.buttonMode = true;
            text.interactive = true;
            text.mouseup = text.tap=callback
          @addChild.call(@,text);
          return text


      addTransparentBg:()->
          bg = PIXI.Sprite.fromImage("imgs/transparent-bg.png");
          bg.position.x = 0;
          bg.position.y = 0;
          @addChild.call(@,bg);


      addPreloader:()->
          texture = PIXI.Texture.fromImage("imgs/preloader.png");
          console.log(texture)
          @preloader=new PIXI.TilingSprite(texture,128,128)
          @preloader.anchor.x = 0.5;
          @preloader.anchor.y = 0.5;
          console.log @
          console.log(@screen)
          @preloader.position.x = @size.width/2;
          @preloader.position.y = @size.height/2+150;
          @addChild.call(@,@preloader);
          @addPreloaderUpdate()

      removeText:()->
        console.log @
        @removeChild(@text)
        @text=null

      removePreloader:()->
        @removeChild(@preloader)
        @preloader=null


      addPreloaderUpdate:()->
          if !@currentPreloaderFrame||@currentPreloaderFrame>9 then @currentPreloaderFrame=0
          @onUpdate(()=>
            if(@preloader)
              @preloader.tilePosition.x-=128
              @currentPreloaderFrame++
          )

      addButton:(imgDefault,imgDown,imgOver,position,callback,context)->
            self=this
#            // create some textures from an image path
            textureButton= PIXI.Texture.fromImage(imgDefault);
            textureButtonDown = PIXI.Texture.fromImage(imgDown);
            button = new PIXI.Sprite(textureButton);
            button.buttonMode = true;
#            // make the button interactive..
            button.interactive = true;
            button.anchor.x = 0.5;
            button.anchor.y = 0.5;
            button.scale.x = @scale.scaleX
            button.scale.y = @scale.scaleY
            button.position.x = position.x
            button.position.y = position.y
            button.mousedown = button.touchstart = (data)->
                if(self.isPaused()) then return
                console.log('111')
                @setTexture(textureButtonDown);

#           // set the mouseup and touchend callback..
            button.mouseup = button.touchend =(data) ->
                if(self.isPaused()) then return
                console.log('222')
                @setTexture(textureButton);

            button.click = button.tap =  (data) ->
              if (self.isPaused()) then return;
              if(callback) then callback.call(context)

            @addChild(button);
            @interactive = true;

   return Scene
)

