define([
    'ScenesManager','text!./../config.json','pixijs'
],  function(ScenesManager,config,PIXI){
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
                   //change current scene
                   this.scenesManager.goToScene('StartScene');
               }
               this.goToCreateGameScene=function(){
                   var roomName=prompt('Enter name of room:')
                   if(roomName!=null){
                       this.createGameScene = this.scenesManager.createScene('CreateGameScene');
                       this.createGameScene.addTransparentBg()
                       this.createGameScene.loadingWait()
                       this.scenesManager.goToScene('CreateGameScene');
                       setTimeout(function(){
                           this.socket.emit('createRoom',{name:roomName})
                       }.bind(this),1500)
                   } else
                       this.goToStartScene()


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
