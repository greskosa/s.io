var config = require('./../config.json');
var io = require('socket.io').listen(config.port);

var connections=0
var rooms={}
var games={}
io.sockets.on('connection', function (socket) {
    console.log('connected')
    function getClientName(id){
        id=id||socket.id
        var ID = (id).toString().substr(0, 8);
        return config.defaultPlayerName+"-"+ID
    }

    function playerCanConnect(roomName,socket){
        return     rooms[roomName].playersCount<config.maxPlayersLimit&&rooms[roomName].host!=getClientName(socket.id)

    }

    function varifyMap(map){
        var sum=0
        for(var i=0;i<10;i++){
            for(var j=0;j<10;j++){
                sum+=map[i][j]
            }
        }
        return sum==config.shipsSum
    }

    function fire(socket,game, cells){
        console.log('FIRE!')
        console.log(cells)
    }
    function connectPlayer(roomName,socket){
        console.log('CONNECT')
        var oldRoom=socket.roomName
        if(oldRoom)
            socket.leave(oldRoom)
        socket.join(roomName)
        socket.roomName=roomName

        rooms[roomName].playersCount++
        console.log(roomName)
        console.log(rooms[roomName].playersCount)
        console.log(config.maxPlayersLimit)
        io.sockets.emit('updateRoomsList',{rooms:rooms});

        if (+rooms[roomName].playersCount==+config.maxPlayersLimit){
            console.log('Load room')
            rooms[roomName].connectedPlayer=getClientName(socket.id)
            io.sockets["in"](roomName).emit('loadRoom',{roomName:roomName})
        }
    }

    function clearRooms(socket){
        console.log('CLEAR')
        var newRoomsList={}
        if(!Object.keys(rooms).length)
            return
        for(var prop in rooms){
            var currentPlayerName=getClientName(socket.id)
            if(games[prop]&&games[prop].maps&&games[prop].maps[currentPlayerName])
                            delete games[prop].maps[currentPlayerName] //destroy game if host have leaved
            if(rooms[prop].host!=currentPlayerName)
                newRoomsList[prop]=rooms[prop]
            else
                delete games[prop]
//            else
//            TODO UNSUBSCRIBE ALL PLAYERS FROM BAD ROOM
//                io.sockets["in"](rooms[prop].roomName).leave()

            if(rooms[prop].connectedPlayer&&currentPlayerName==rooms[prop].connectedPlayer)
                rooms[prop].playersCount--

        }
        rooms=newRoomsList
        socket.broadcast.emit('updateRoomsList',{rooms:rooms});
    }

    connections++;
    socket.on('createRoom',function(data){
//        console.log(socket.clients)
        var roomsCount=Object.keys(rooms).length
//        console.log(config.maxRoomsLimit)
//        console.log(roomsCount)
        if(roomsCount<+config.maxRoomsLimit){
            if(data.name&&!rooms[data.name]){
                rooms[data.name]={roomName:data.name, host:getClientName(), playersCount:0,created:new Date().getTime()}
                connectPlayer(data.name,socket)
                socket.json.send({'event': 'roomCreatedSuccess'})
            }else{
                console.log('no create')
                socket.json.send({'event': 'roomNameNoAvailable'})
            }
        }else{
            socket.json.send({'event': 'maxRoomsLimit'})
        }

    })
    socket.on('getAllRooms',function(data){
        socket.json.send({'event': 'gamesList', rooms : rooms})
    })
    socket.on('switchRoom',function(roomName){
       if (!rooms[roomName])
        return
       if(playerCanConnect(roomName,socket)){
           connectPlayer(roomName,socket)
       }
       else
           socket.json.send({'event': 'connectCancel', 'msg': 'Sorry,room is full.'});
    })

    socket.on('sendShipsPosition',function(data){
        if(!varifyMap(data.map)){
            socket.json.send({'event': 'disconnected', 'msg': "You are cheating. You was disconnected!"});
            io.sockets.connected[socket.id].disconnect();
            return
        }
        var currentPlayerName=getClientName(socket.id)
        var roomName=data.roomName
        if(!games[roomName]) //if new emty room
            games[roomName]={maps:{}}
        games[roomName]['maps'][currentPlayerName]=data.map
        if(rooms[roomName].host==currentPlayerName)
            games[roomName].currentPlayer=currentPlayerName
        if(Object.keys(games[roomName]['maps']).length>1){
            console.log('start GAME!!!')
            var roomsClients=io.nsps['/'].adapter.rooms[roomName]
            console.log(roomsClients)
            for(var id in roomsClients){
                var isYourTurn=rooms[roomName].host==getClientName(id)
                console.log(id)
                console.log(isYourTurn)
                io.to(id).emit('startGame', { isYourTurn: isYourTurn });
            }

//            io.sockets["in"](roomName).forEach(function(eachSocket){
//                var isYourTurn=rooms[roomName].host==getClientName(eachSocket.id)
//                eachSocket.emit('startGame',{isYourTurn:isYourTurn})
//            })
        }
        else{
            console.log('waitOtherPlayerBeforeStart')
            socket.emit('waitOtherPlayerBeforeStart')
        }

    })
    socket.on('disconnect', function () {
        console.log('disconect')
        connections--;
        clearRooms(socket)
        console.log(games)
    });
    socket.on('fire',function(data){
        var roomName=data.roomName
        var cells=data.cells
        if(!roomName)
            return console.log('roomname missed')
        var game=games[roomName]
        if(!game)
            return console.log('error')
        var playerName=getClientName(socket.id)
        if(playerName!=game.currentPlayer)
            return 'not your turn'
        if(!game.maps.hasOwnProperty(playerName))
            return 'you not in this game'
        fire(socket,game,cells)

    })
    var time = (new Date).toLocaleTimeString();
    socket.json.send({'event': 'connected', 'name': getClientName(), 'time': time});
//    socket.broadcast.json.send({'event': 'userJoined', 'name': playerString+connections, 'time': time});


});
console.log('start')