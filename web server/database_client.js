var mysql = require('mysql');
var moment = require('moment')
const fs = require('fs');


class DatabaseClient{

    constructor(ip, port, database, username, password) {
        this.connection = mysql.createConnection({
            host: ip,
            port: port,
            database: database,
            user: username,
            password: password,
            dateStrings: true
        });

        this.connection.connect(function (err) {
            if(err) throw err;
            console.log("Connected to database");
        })
    }

    getConnection(){
        return this.connection;
    }


    async generate_summary(databaseHeader) {

        var sql = "";
        try{
            var json_date = fs.statSync('data/summary.json').mtime;
            json_date = moment(json_date, "YYYY-MM-DD")

            sql = "call getLastUpdate()";
            const result = await this.execute_query(sql);
            const db_date = moment(result[0][0].UPDATE_TIME, "YYYY-MM-DD");

            if (json_date > db_date){
                console.log('Use summary.json from cache');
                return;
            }
        }catch(err){
            console.log('Create new summary.json file', err);
        }


        var headers = [... databaseHeader];
        var table = [];

        //TODO - use view
        sql = "SELECT DataPagamento, BollettaID, Utenza, ImportoTotale, Scadenza FROM Bollette";
        var bollette = await this.execute_query(sql);

        sql = "SELECT Nome From Coinquilini";
        var coinquilini = await this.execute_query(sql);
        coinquilini.forEach(function (c) {
            headers.push(c.Nome)
        });

        sql = "SELECT * FROM Pagamenti";
        var pagamenti = await this.execute_query(sql);

        bollette.forEach(function (b) {
           var row = {};

           headers.forEach(function (h) {

               if (headers.indexOf(h) > databaseHeader.length - 1){
                   pagamenti.forEach(function (p) {
                       if (p.BollettaID === b.BollettaID && p.NomeCoinquilino === h){
                           var importo = p.Importo;
                           row[h] = ((p.DataPagamento != null) ? importo+'€' : '-'+importo+'€');    //not payed yet
                       }
                   });
               }
               else if (headers.indexOf(h) === 0){
                   row[h] = ((b[h] != null) ? 'OK' : '');   //TODO add checkbox
               }
               else if (String(b[h]).includes('-')){
                   row[h] = moment(b[h], "YYYY-MM-DD").format('DD-MM-YYYY');
               }
               else{
                   row[h] = b[h];
               }
           });

            table.push(row);
        });

        //TODO riga totale

        let data = JSON.stringify(table);
        fs.writeFileSync('data/summary.json', data);
    }



    execute_query(sql){

        var connection = this.getConnection();

        return new Promise(function (resolve, reject) {
            connection.query(sql, function (err, data) {
                if (err) {
                    reject(err);
                }
                resolve(data);
            });
        });
    }



}//end Class

module.exports = DatabaseClient;