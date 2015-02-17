define([
    'text!../../config.json','require','game'
],  function(config,require,game){
    config=JSON.parse(config)
    game.addGameTitle()
    require([config.server+":"+config.port+"/socket.io/socket.io.js"],function(io){
        var socket = io.connect('http://localhost:8080');
           socket.on('connect', function () {
//               socket.send('hi');

               socket.on('message', function (msg) {
                  switch(msg.event){
                      case "connected":
                          console.log(game)
                          game.addSuccesStageUi(msg.name)
                          break;

                  }
               });
           });
    },function(err){
        game.addFailedStageUi('Connection problem, try later.')
    })

}

)
