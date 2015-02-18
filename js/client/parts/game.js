define([
    'ScenesManager','text!./../config.json'
],  function(ScenesManager,config){
        config=JSON.parse(config)
        function Game(){
               var screen={}
               screen.width=window.outerWidth>config.originalWidth? config.originalWidth:window.outerWidth
               screen.height=window.outerHeight>config.originalHeight? config.originalHeight:window.outerHeight
               screen.scaleX=screen.width/config.originalWidth
               screen.scaleY=screen.height/config.originalHeight

               this.scenesManager=new ScenesManager()
               //create renderer
               this.scenesManager.create(screen,{transparent:true})

               this.goToStartScene=function(){
                   //create a the start scene
                   this.startScene = this.scenesManager.createScene('StartScene');
                   this.startScene.addGameTitle()
                   //change current scene
                   this.scenesManager.goToScene('StartScene');
               }
               this.goToCreateGameScene=function(){
                   alert(1)
                   this.createScene = this.scenesManager.createScene('CreateGameScene');
                   this.scenesManager.goToScene('CreateGameScene');
               }
               this.goToJoinGameScene=function(){
                   alert(2)
                   this.createScene = this.scenesManager.createScene('JoinGameScene');
                   this.scenesManager.goToScene('JoinGameScene');

               }
               this.goToStartScene()

        }
     return new Game()
    }
)

