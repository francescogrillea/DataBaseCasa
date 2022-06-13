const http = require('http');
var express = require('express');
var config = require('./config.json');
const DatabaseClient = require('./database_client.js');
const pug = require('pug');
const fs = require("fs");


const PORT = config.serverPort;
const IP = config.serverIP;
const URL = 'http://' + IP + ':' + PORT;
var summaryHeader = config.summaryHeader;
const statsHeader = config.statsHeader;
const databaseHeader = config.databaseHeader;

//Connect to database
const database = new DatabaseClient(config.databaseIP,config.databasePort,config.databaseName,config.databaseUser,config.databasePassword, databaseHeader);

app = express()
app.use(express.json());
app.set('view engine', 'pug');
app.use(express.static("public"));

const server = http.createServer(app);
server.listen(PORT, IP);
console.log('Node.js web server started at %s', URL);


app.get('/*', async function (req, res) {
    console.log('Received: %s', req.url)

    if (req.url === '/bollette') {
        await database.generate_summary(databaseHeader);
        var raw_data = fs.readFileSync('data/summary.json');
        var content = JSON.parse(raw_data);

        res.render('bollette_summary', {title: 'Bollette', header: summaryHeader.concat(Object.keys(content[0]).slice(5)), bollette: content});
    }

    else if (req.url === '/bollette?query=stats') {
        await database.generate_stats();
        var raw_data = fs.readFileSync('data/stats.json');
        var content = JSON.parse(raw_data);


        res.render('bollette_stats', {title: 'Statistiche Bollette', header: statsHeader, bollette: content});
    }

    else if (req.url === '/home') {
        res.render('homepage', {title: 'Welcome to Rebibbia 2.0'});
    }

    //redirect to home
    else {
        res.redirect(URL + '/home')
    }
});