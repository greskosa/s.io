define([
    'pixijs','Scene', 'text!./../config.json'
],  function(PIXI,Scene,config){
    var config=JSON.parse(config)

  function CreateGameScene(){
     this.loadingWait=function(){
         var textMessage='Loading. Please wait...'
         if(!this.text)
            this.text=this.addText(textMessage,{font:"40px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:this.size.width/2,y:this.size.height/2})
         else
             this.text.setText(textMessage)
     }
    this.changeText=function(text){
        if(this.text) this.text.setText(text)
    }



  }
    CreateGameScene.prototype=new Scene()
    CreateGameScene.prototype.constructor=CreateGameScene

    return CreateGameScene
}
)

