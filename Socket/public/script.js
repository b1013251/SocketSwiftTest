var socket = io();

$(function(){

socket.on('chat message', function(msg) {
    $("#messages").append($('<li>').text(msg));
});

$('form').submit(function(){
      socket.emit('chat message', $('#message_box').val());
      $('#message_box').val('');
      return false;
    });
});

