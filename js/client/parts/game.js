define([
    'ScenesManager'
],  function(ScenesManager){
        function Game(){
               this.canvasWidth=window.outerWidth>800? 800:window.outerWidth
               this.canvasHeight=window.outerHeight>600? 600:window.outerHeight
               this.scenesManager=new ScenesManager()
               //create renderer
               this.scenesManager.create(this.canvasWidth,this.canvasHeight,{transparent:true})
               //create a the start scene
               this.startScene = this.scenesManager.createScene('StartScene');
               this.startScene.addGameTitle({x:this.canvasWidth/2,y:this.canvasHeight/3})
               this.startScene.addButton('./imgs/button.png','./imgs/buttonDown.png',null,{x:this.canvasWidth/2,y:this.canvasHeight*0.7})
               //change current scene
               this.scenesManager.goToScene('StartScene');
        }

     return new Game()
    }
)

