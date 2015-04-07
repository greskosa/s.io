var config = require('./../config.json');
var io = require('socket.io').listen(config.port);

var connections=0
var rooms={}
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
            console.log('START GAME')
            rooms[roomName].connectedPlayer=getClientName(socket.id)
            io.sockets["in"](roomName).emit('startGame')
        }
    }

    function clearRooms(socket){
        console.log('CLEAR')
//        console.log(rooms)
        var newRoomsList={}
        if(!Object.keys(rooms).length)
            return
//        console.log(rooms)
//        console.log(io.sockets)
        for(var prop in rooms){
            currentPlayerName=getClientName(socket.id)
            if(rooms[prop].host!=currentPlayerName)
                newRoomsList[prop]=rooms[prop]
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
    socket.on('disconnect', function () {
        console.log('disconect')
        connections--;
        clearRooms(socket)
    });
    var time = (new Date).toLocaleTimeString();
    socket.json.send({'event': 'connected', 'name': getClientName(), 'time': time});
//    socket.broadcast.json.send({'event': 'userJoined', 'name': playerString+connections, 'time': time});


});
console.log('start')