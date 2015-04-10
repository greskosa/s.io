define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)

    class CreateGameScene extends Scene
      constructor:(screen)->
          super(screen)
          @click = @tap =  (data) ->
            console.log('3333')
          @addTransparentBg()
          @loadingWait()

      loadingWait:()->
         textMessage='Loading. Please wait...'
         if(!@text)
            @text=@addText(textMessage,{font:"40px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:@size.width/2+10,y:@size.height/2})
         else
             @text.setText(textMessage)


      waitingOtherPlayer:()->
        @changeText('Waiting for the other player...')
        @addPreloader(true)

      changeText:(text)->
        if(@text) then @text.setText(text)

    return CreateGameScene

)

