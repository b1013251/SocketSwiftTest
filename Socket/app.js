var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var fs = require('fs');

app.use(express.static('./public'));

io.on('connection', function(socket) {
    console.log("User Connected");

    socket.on('disconnect', function() {
        console.log("User Disconnected");
    });

    // Text
    socket.on('chat message', function(msg) {
        console.log("Chat Message: " + msg)
        if(msg == "" || msg == null) {
            return
        }
        io.emit('chat message', msg)
    })

    // Image
    socket.on('image_from_client', function(data) {
        console.log("Arrived Image");
        fs.writeFile("output.jpg", data, function(err) {
           if(err != null) {
               console.log("Write Error");
           } else {
               console.log("Written!");
           }
        });

        fs.readFile("yuno.jpg", function(err, yuno) {
            if(err != null) {
                console.log("Read Error");
            } else {
                io.emit('image_from_server', yuno);
            }
        });
    });

    // JSON
    socket.on('json_from_client', function(json_str) {
        console.log("Get JSON");
        var json = JSON.parse(json_str);
        Object.keys(json).forEach(function (key) {
            console.log(key + " : " + json[key]);
        });
        var json = {
            name: "newsoku de yaranaio",
            job: "mushoku"
        }
        io.emit('json_from_server', JSON.stringify(json));
    });
});

http.listen(8000, function(req, res) {
    console.log("listening...");
});