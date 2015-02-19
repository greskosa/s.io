var config = require('./../config.json');
var io = require('socket.io').listen(config.port);

var connections=0
var rooms={}
io.sockets.on('connection', function (socket) {
    connections++;
    var ID = (socket.id).toString().substr(0, 8);
//    socket.on('message', function (msg) {
//     console.log('message')
//     console.log(msg)
//
//    });
    socket.on('createRoom',function(data){
        var roomsCount=Object.keys(rooms).length
        console.log(config.maxRoomsLimit)
        console.log(roomsCount)
        if(roomsCount<+config.maxRoomsLimit){
            if(data.name&&!rooms[data.name]){
                rooms[data.name]=true
                console.log('create')
                socket.json.send({'event': 'roomCreatedSuccess'})
            }else{
                console.log('no create')
                socket.json.send({'event': 'roomNameNoAvailable'})
            }
        }else{
            socket.json.send({'event': 'maxRoomsLimit'})
        }

    })
    socket.on('disconnect', function () {
        console.log('disconect')
        connections--;
    });
    var time = (new Date).toLocaleTimeString();
    socket.json.send({'event': 'connected', 'name': config.defaultPlayerName+"-"+ID, 'time': time});
//    socket.broadcast.json.send({'event': 'userJoined', 'name': playerString+connections, 'time': time});
});
console.log('start')