define([
    'pixijs','Scene', 'text!./../config.json'
],  function(PIXI,Scene,config){
    var config=JSON.parse(config)

  function StartScene(){

     this.addGameTitle=function(position){
         this.addText(config.appName,{font:"50px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},position)
     }
     this.addSuccesStageUi=function(name,position){
          this.addStartBtns()
          this.addPlayerName(name,position)
     }
     this.addFailedStageUi=function(err,position){
          this.addErrorMessage(err,position)
     }
    this.addStartBtns=function(){


     }
    this.addErrorMessage=function(msg,position){
      console.log(msg)
      this.addText(msg,{font:"28px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 3},position)
    }
    this.addPlayerName=function(name,position){
      this.addText("Your name:"+name,{font:"16px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 2},position)
    }

  }
    StartScene.prototype=new Scene()
    StartScene.prototype.constructor=StartScene

    return StartScene
}
)

