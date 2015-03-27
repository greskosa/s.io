define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)
    class StartScene extends Scene
      paused:false
      constructor:(screen)->
        super(screen)
        @addGameTitle()


      updateCallback:()->
#        console.log('update')

      addGameTitle:()->
         console.log(@size)
         @addText(config.appName,{font:"56px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:@size.width/2,y:@size.height/3})

      addSuccesStageUi:(name,createGameCallback,joinGameCallback,context)->
        @addPlayerName(name)
        @addButton('./imgs/creategame.png','./imgs/creategameDown.png',null,{x:@size.width/2,y:@size.height*0.62},createGameCallback,context)
        @addButton('./imgs/joingame.png','./imgs/joingameDown.png',null,{x:@size.width/2,y:@size.height*0.80},joinGameCallback,context)


      addFailedStageUi:(err,position)->
        @addErrorMessage(err,position)

      addErrorMessage:(msg)->
        @addText(msg,{font:"28px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 4},{x:@size.width/2,y:@size.height*2/3})

      addPlayerName:(name)->
        @addText("Your name: "+name,{font:"23px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 2},{x:@size.width*0.8,y:20})

    return StartScene
)

