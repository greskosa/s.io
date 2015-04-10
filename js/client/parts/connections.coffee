define([
    'text!../../config.json','require','game'
],  (config,require,game)->
    config=JSON.parse(config)
    disconnected=(msg)->
      alert(msg) if msg
      setTimeout(()->
        location.reload()
      ,3000)

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
                  when "roomCreatedSuccess" then game.createGameScene.waitingOtherPlayer()
                  when "maxRoomsLimit"
                      game.createGameScene.changeText('Max limit of rooms was reached. Try later.')
                      setTimeout(()->
                          game.goToStartScene()
                      ,2500)
                  when "gamesList"
                    game.joinGameScene.renderAvailableRooms(msg.rooms) if game.joinGameScene

                  when "connectCancel"
                    game.joinGameScene.clearConnecting() if game.joinGameScene
                    alert(msg.msg)

                  when "disconnected"
                    disconnected(msg.msg)
           );
          socket.on('loadRoom',  (roomName)->
              game.loadRoom(roomName)
          )
          socket.on('updateRoomsList',  (msg)->
            roomName=if game.gameScene then game.gameScene.roomName else false
            if(roomName&&msg.rooms&&!msg.rooms[roomName])
              socket.disconnect();
              disconnected('Connection with host lost. You win!!!')
            game.joinGameScene.renderAvailableRooms(msg.rooms) if game.joinGameScene
          )
          socket.on('connect_error', () ->
                  disconnected('Sorry server is down. Try again later!')
                  socket.disconnect();
          );
          socket.on('waitOtherPlayerBeforeStart',()->
            game.gameScene.waitOtherPlayerBeforeStart() if game.gameScene
          )
          socket.on('startGame',()->
            game.gameScene.startGame() if game.gameScene
          )
        )
      ,(err)->
        game.startScene.addFailedStageUi('Connection problem, try later.')
      )


)