var express = require('express');
var app = express();
app.use(express.static('public'));
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = process.env.PORT || 3000;

const SerialPort = require('serialport')
const Readline = require('@serialport/parser-readline')

var portName = process.argv[2] ? process.argv[2] : '/dev/ttyUSB0';	
console.log("***** Server Farm Controller  *****")
console.log("opening serial port: " + portName);	

var myPort = new SerialPort(portName,{ 
	baudRate: 9600
});

const parser = myPort.pipe(new Readline({ delimiter: '\r' }))
parser.on('data',  console.log)

io.on('connection', function(socket) {
    console.log('user is connected')

    socket.on('tx', function(tx) {
        console.log('tx: '+ tx);
        myPort.write(tx, function(err) {		
          
        }); 
    });

    parser.on('data', function(rx) {
            console.log('rx: '+ rx);
            socket.emit('rx', "" + rx);
    });    
});


async function printPorts() {
  console.log()
  console.log("***** Serial Ports *****")

  let ports = await SerialPort.list()

  ports.forEach(function(port) {
    console.log()
    if (port.path) console.log(port.path);
    if (port.manufacturer) console.log(" > Manufacturer: " + port.manufacturer)
    if (port.pnpId) console.log(" > PnP ID: " + port.pnpId);
  
  });
  
  console.log("************************")
  console.log()
}

printPorts()


app.get('/', function(req, res) {
 res.sendFile(__dirname + '/public/index.html');
});

http.listen(port, function() {
    console.log('listening on *: ' + port);   
});

