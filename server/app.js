var express = require('express');
var app = express();
app.use(express.static('public'));
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = process.env.PORT || 3000;

var serialport = require("serialport");	
var SerialPort = serialport.SerialPort;

SerialPort.list(function (err, ports) {
  ports.forEach(function(port) {
    console.log(port.comName);
    console.log(port.pnpId);
    console.log(port.manufacturer);
  });
});

var portName = process.argv[2] ? process.argv[2] : 'com4';	

// print out the port you're listening on:
console.log("opening serial port: " + portName);	
var myPort = new SerialPort(portName, { 
	baudRate: 9600
});

const parser = myPort.pipe(new ReadlineParser()) 

io.on('connection', function(socket) {
    console.log('user is connected')

    socket.on('tx', function(tx) {
        console.log('tx: '+ tx);
        myPort.write(tx, function(err) {		
          
        }); 
    });

    parser.on('data',  function(rx) {
        console.log('rx: '+ rx);
        socket.emit('rx', "" + rx);
    });  

    // myPort.on('data', function(rx) {
    //         console.log('rx: '+ rx);
    //         socket.emit('rx', "" + rx);
    // });    
});

app.get('/', function(req, res) {
 res.sendFile(__dirname + '/public/index.html');
});

http.listen(port, function() {
    console.log('listening on *: ' + port);   
});

