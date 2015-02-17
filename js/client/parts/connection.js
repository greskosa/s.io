define([
    'text!../../config.json','require'
],  function(config){
    config=JSON.parse(config)
    require([config.server+":"+config.port+"/socket.io/socket.io.js",'canvas'],function(io){
        var socket = io.connect('http://localhost:8080');
           socket.on('connect', function () {
               socket.send('hi');

               socket.on('message', function (msg) {
                   // my msg
                   console.log(msg)
               });
           });
    })

}

)
