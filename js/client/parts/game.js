define([
    'ScenesManager','text!./../config.json','pixijs'
],  function(ScenesManager,config,PIXI){
        config=JSON.parse(config)
        function Game(){
               this.scenesManager=new ScenesManager()
               //create renderer
               this.scenesManager.create({transparent:true},true)

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
                       this.scenesManager.goToScene('CreateGameScene');
                       setTimeout(function(){
                           this.socket.emit('createRoom',{name:roomName})
                       }.bind(this),1500)
                   } else
                       this.goToStartScene()


               }
               this.goToJoinGameScene=function(){
                   this.joinGameScene = this.scenesManager.createScene('JoinGameScene');
                   this.scenesManager.goToScene('JoinGameScene');
                   this.socket.emit('getAllRooms')
                   this.joinGameScene.connect2Room=function(room){
                                      this.socket.emit('switchRoom',room.roomName)
                                  }.bind(this)
               }


               this.loadRoom=function(data){
                   var loader = new PIXI.AssetLoader(config.assetsToLoad);
                   loader.onComplete = function(all){
                        document.getElementsByTagName('canvas')[0].style.background="url('./imgs/bginroom.jpg')"
                        this.gameScene = this.scenesManager.createScene('GameScene');
                        this.gameScene.roomName=data.roomName
                        this.scenesManager.goToScene('GameScene');
                        this.gameScene.sendShips=function(map){
                            console.log('send ship')
                            this.socket.emit('sendShipsPosition',{map:map,roomName:data.roomName})
                        }.bind(this)
                        this.gameScene.fire=function(cell){
                            console.log('fire!')
                            this.socket.emit('fire',{roomName:this.gameScene.roomName,cell:cell})
                        }.bind(this)
                   }.bind(this)
                   loader.load();

               }

               this.goToStartScene()

        }
      window.game=new Game()
      return window.game
    }
)
