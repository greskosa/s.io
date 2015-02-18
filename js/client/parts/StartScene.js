define([
    'pixijs','Scene', 'text!./../config.json'
],  function(PIXI,Scene,config){
    var config=JSON.parse(config)

  function StartScene(){
     this.addGameTitle=function(){
         this.addText(config.appName,{font:"56px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:this.size.width/2,y:this.size.height/3})
     }
     this.addSuccesStageUi=function(name,createGameCallback,joinGameCallback,context){
         this.addButton('./imgs/creategame.png','./imgs/creategameDown.png',null,{x:this.size.width/2,y:this.size.height*0.62},createGameCallback,context)
         this.addButton('./imgs/joingame.png','./imgs/joingameDown.png',null,{x:this.size.width/2,y:this.size.height*0.80},joinGameCallback,context)
         this.addPlayerName(name)
     }
     this.addFailedStageUi=function(err,position){
          this.addErrorMessage(err,position)
     }
    this.addErrorMessage=function(msg){
      this.addText(msg,{font:"28px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 4},{x:this.size.width/2,y:this.size.height*2/3})
    }
    this.addPlayerName=function(name){
      this.addText("Your name: "+name,{font:"23px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 2},{x:this.size.width*0.8,y:20})
    }


  }
    StartScene.prototype=new Scene()
    StartScene.prototype.constructor=StartScene

    return StartScene
}
)

