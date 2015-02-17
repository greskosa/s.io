define([
    'ScenesManager'
],  function(ScenesManager){
        function Game(){
               this.canvasWidth=window.outerWidth>1024? 1024:window.outerWidth
               this.canvasHeight=window.outerHeight>768? 768:window.outerHeight
               this.scenesManager=new ScenesManager()
               //create renderer
               this.scenesManager.create(this.canvasWidth,this.canvasHeight,{transparent:true})
               //create a the start scene
               this.startScene = this.scenesManager.createScene('StartScene');
               this.startScene.addGameTitle()
               //change current scene
               this.scenesManager.goToScene('StartScene');
        }

     return new Game()
    }
)

