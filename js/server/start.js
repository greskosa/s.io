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
        return  rooms[roomName].playersCount<config.maxPlayersLimit&&rooms[roomName].host!=getClientName(socket.id)
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
    function validateCell(x,y){
        if (x>9 || x<0 || y<0 || y>9)
           return false
        return true
    }

    function isKilled(map,cells,x,y,direction){
//        debugger
        var left=false,right=false,up=false,down=false,cell;
        if((!direction&&validateCell(x,y-1))||(direction&&direction!='down'&&validateCell(x,y-1))){
            cell=map[y-1][x]
            if(cell==0||cell==config.statusMissed){
                up=true
                cells.push({x:x,y:y-1})
            }else if(cell==config.statusInjured){
                up=isKilled(map,cells,x,y-1,'up')
            }
        }else{
            up=true
        }
        if((!direction&&validateCell(x,y+1))||(direction&&direction!='up'&&validateCell(x,y+1))){
            cell=map[y+1][x]
            if(cell==0||cell==config.statusMissed){
                down=true
                cells.push({x:x,y:y+1})
            }else if(cell==config.statusInjured){
                down=isKilled(map,cells,x,y+1,'down')
            }
        }else{
            down=true
        }
        if((!direction&&validateCell(x-1,y))||(direction&&direction!='right'&&validateCell(x-1,y))){
            cell=map[y][x-1]
            if(cell==0||cell==config.statusMissed){
                left=true
                cells.push({x:x-1,y:y})
            }else if(cell==config.statusInjured){
                left=isKilled(map,cells,x-1,y,'left')
            }
        }else{
            left=true
        }
        if((!direction&&validateCell(x+1,y))||(direction&&direction!='left'&&validateCell(x+1,y))){
            cell=map[y][x+1]
            if(cell==0||cell==config.statusMissed){
                right=true
                cells.push({x:x+1,y:y})
            }else if(cell==config.statusInjured){
                right=isKilled(map,cells,x+1,y,'right')
            }
        }else{
            right=true
        }
        return left&&right&&up&&down
    }
    function markCells(map,y,x,cells){
        map[y][x]=config.statusInjured
        var status

        if(!isKilled(map,cells,x,y)){
//        injured!
            console.log('injured')
            status=config.statusInjured
        }else{
//            killed!
            console.log('killed')
            if(validateCell(x-1,y-1))
                cells.push({x:x-1,y:y-1})
            if(validateCell(x+1,y-1))
                cells.push({x:x+1,y:y-1})
            if(validateCell(x-1,y+1))
                cells.push({x:x-1,y:y+1})
            if(validateCell(x+1,y+1))
                cells.push({x:x+1,y:y+1})
            var arrLength=cells.length
            for(var i=0;i<arrLength;i++){
                var obj=cells[i]
                map[obj.y][obj.x]=config.statusMissed
            }
            status=config.statusKilled
        }
        return status

    }
    function fire(socket,roomName,game, cell){
//        Shot map
//        0 - empty cell
//        1 - cell with ship or part of ship
//        2 - missed
//        3 - injured or killed
//
//        Status
//        2 - missed
//        3 - injured
//        4 - killed
        var y=cell.y
        var x=cell.x
        var updateCells=[]
        console.log(cell)
//        console.log("currentPlayer:"+getClientName(socket.id))
        var roomsClients=io.nsps['/'].adapter.rooms[roomName]
//        console.log(JSON.stringify(game))
        var response={}
        var status
        for(var id in roomsClients){
            var playerName=getClientName(id)
            response[playerName]={}
            console.log('current player:'+game.currentPlayer)
            var isYourTurn=game.currentPlayer==playerName
            console.log(isYourTurn)
            if(!isYourTurn){
                if (game.maps[playerName][y][x]==config.statusMissed||game.maps[playerName][y][x]==config.statusInjured)
                  return console.log("you have already fired here!")
                if(game.maps[playerName][y][x]==1){
                    status=markCells(game.maps[playerName],y,x,updateCells)
                }else{
                    game.maps[playerName][y][x]=config.statusMissed
                    console.log('change player to:'+playerName)
                    game.currentPlayer=playerName
                    status=config.statusMissed
                }
                break;
            }
        }
        var responseUpdateCells=status==config.statusKilled?updateCells:[]
        for(var id in roomsClients){
           var plName=getClientName(id)
           var isYourTurn=game.currentPlayer==plName
           console.log(id)
           console.log(isYourTurn)
           io.to(id).emit('fireResponse', { isYourTurn: isYourTurn,cell:{x:x,y:y},status:status,map: game.maps[plName],updateCells:responseUpdateCells});
       }
//        console.log(status)
//        console.log(JSON.stringify(game))

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
        var cell=data.cell
        if(!roomName)
            return console.log('roomname missed')
        var game=games[roomName]
        if(!game)
            return console.log('error')
        var playerName=getClientName(socket.id)
        if(playerName!=game.currentPlayer)
            return console.log('not your turn')
        if(!game.maps.hasOwnProperty(playerName))
            return console.log('you not in this game')
        fire(socket,roomName,game,cell)

    })
    var time = (new Date).toLocaleTimeString();
    socket.json.send({'event': 'connected', 'name': getClientName(), 'time': time});
//    socket.broadcast.json.send({'event': 'userJoined', 'name': playerString+connections, 'time': time});


});
console.log('start')