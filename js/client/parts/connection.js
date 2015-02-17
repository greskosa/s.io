define([
    'text!../../config.json','require','game'
],  function(config,require,game){
    config=JSON.parse(config)
    require([config.server+":"+config.port+"/socket.io/socket.io.js"],function(io){
        var socket = io.connect(config.server+":"+config.port);
           socket.on('connect', function () {

               socket.on('message', function (msg) {
                  switch(msg.event){
                      case "connected":
                          game.startScene.addSuccesStageUi(msg.name)
                          break;

                  }
               });
           });
    },function(err){
        game.startScene.addFailedStageUi('Connection problem, try later.')
    })

}

)
