var socket = io.connect('http://localhost:8080');
socket.on('connect', function () {
    socket.send('hi');

    socket.on('message', function (msg) {
        // my msg
        console.log(msg)
    });
});
