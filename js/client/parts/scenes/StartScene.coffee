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
       @addText(config.appName,{font:"66px Fjalla One", fill:"#ecf1f1",stroke: "#434945", strokeThickness: 8, dropShadow:true, dropShadowDistance:4,dropShadowColor:'#000000'},{x:config.originalWidth/2,y:config.originalHeight/3})

    addSuccesStageUi:(name,createGameCallback,joinGameCallback,context)->
      @addPlayerName(name)
      @addButton('./imgs/creategame.png','./imgs/creategameDown.png',null,{x:config.originalWidth/2,y:config.originalHeight*0.62},createGameCallback,context)
      @addButton('./imgs/joingame.png','./imgs/joingameDown.png',null,{x:config.originalWidth/2,y:config.originalHeight*0.80},joinGameCallback,context)


    addFailedStageUi:(err,position)->
      @addErrorMessage(err,position)

    addErrorMessage:(msg)->
      @addText(msg,{font:"28px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 4},{x:config.originalWidth/2,y:config.originalHeight*2/3})

    addPlayerName:(name)->
      window.playerName=name
      if(!@playerName)
        @playerName=@addText("Your name: "+name,{font:"23px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 2},{x:config.originalWidth*0.8,y:20})
      else
        @playerName.setText("Your name: "+name)

  return StartScene
)

