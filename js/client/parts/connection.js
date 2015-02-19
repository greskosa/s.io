define([
    'text!../../config.json','require','game'
],  function(config,require,game){
    config=JSON.parse(config)
    require([config.server+":"+config.port+"/socket.io/socket.io.js"],function(io){
        var socket = io.connect(config.server+":"+config.port);
        game.socket=socket
           socket.on('connect', function () {

               socket.on('message', function (msg) {
                  switch(msg.event){
                      case "connected":
                          game.startScene.addSuccesStageUi(msg.name,game.goToCreateGameScene,game.goToJoinGameScene,game)
                          break;
                      case "roomNameNoAvailable":
                          game.createGameScene.changeText('Room name is not available.Try another one.')
                          setTimeout(function(){
                              game.goToCreateGameScene()
                          },2500)
                          break;
                      case "roomCreatedSuccess":
                          game.goToStartScene()
                          break;
                      case "maxRoomsLimit":
                          game.createGameScene.changeText('Max limit of rooms was reached. Try later.')
                          setTimeout(function(){
                              game.goToStartScene()
                          },2500)
                          break;
                  }
               });
           });
    },function(err){
        game.startScene.addFailedStageUi('Connection problem, try later.')
    })

}

)
