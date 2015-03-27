define([
    'text!../../config.json','require','game'
],  (config,require,game)->
    config=JSON.parse(config)
    require([config.server+":"+config.port+"/socket.io/socket.io.js"],(io)->
        socket = io.connect(config.server+":"+config.port);
        game.socket=socket
        socket.on('connect',  () ->
           socket.on('message',  (msg)->
              switch msg.event
                  when "connected" then  game.startScene.addSuccesStageUi(msg.name,game.goToCreateGameScene,game.goToJoinGameScene,game)
                  when "roomNameNoAvailable"
                      game.createGameScene.changeText('Room name is not available.Try another one.')
                      setTimeout(()->
                          game.goToCreateGameScene()
                      ,2500)
                  when "roomCreatedSuccess" then game.goToStartScene()
                  when "maxRoomsLimit"
                      game.createGameScene.changeText('Max limit of rooms was reached. Try later.')
                      setTimeout(()->
                          game.goToStartScene()
                      ,2500)
           );
        )
      ,(err)->
        game.startScene.addFailedStageUi('Connection problem, try later.')
      )


)