define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)

    class GameScene extends Scene
      constructor:(screen)->
          super(screen)
          @click = @tap =  (data) ->
            console.log('3333')
#          @addTransparentBg()
#          @loadingWait()



      changeText:(text)->
        if(@text) then @text.setText(text)

    return GameScene

)

