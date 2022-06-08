DROP PROCEDURE getStats;

DELIMITER $$
CREATE PROCEDURE getStats()
BEGIN
	SELECT Utenza,
		ROUND(DATEDIFF(MAX(Scadenza), MIN(Scadenza)) / (COUNT(*) - 1) / 30) as Periodicita,
        DATE_ADD(MAX(Scadenza), INTERVAL ROUND(DATEDIFF(MAX(Scadenza), MIN(Scadenza)) / (COUNT(*) - 1)) DAY) as ProssimaScadenza,
		avg(ImportoTotale) as ImportoMedio, stddev(ImportoTotale) as VariazioneImportoMedio, avg(ImportoTotale) / 5 as ImportoMedioPersona,
		avg(ImportoTotale) * (30 / ROUND(DATEDIFF(MAX(Scadenza), MIN(Scadenza)) / (COUNT(*) - 1))) as ImportoMensile,
        (avg(ImportoTotale) * (30 / ROUND(DATEDIFF(MAX(Scadenza), MIN(Scadenza)) / (COUNT(*) - 1)))) / 5 as ImportoMensilePersona
	FROM Bollette
	GROUP BY Utenza
;END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE getLastUpdate()
BEGIN
	SELECT UPDATE_TIME
	FROM   information_schema.tables
	WHERE  TABLE_SCHEMA = 'rebibbia2' AND TABLE_NAME = 'Pagamenti'
;END $$
DELIMITER ;


DELIMITER //
-- Visualizza l'importo toale delle bollette che il coinquilino deve pagare
CREATE PROCEDURE quotaTotale(nome VARCHAR(32))
BEGIN
	SELECT sum(P.Importo) as Totale
	FROM Bollette B, Pagamenti P
	WHERE P.NomeCoinquilino = nome AND P.DataPagamento IS NULL AND B.BollettaID = P.BollettaID
	;
END;//
DELIMITER ;


DELIMITER //
-- Visualizza l'importo toale delle bollette che il coinquilino deve pagare
CREATE PROCEDURE getQuote(bolletta VARCHAR(32))
BEGIN
	SELECT P.NomeCoinquilino, P.DataPagamento, P.Importo
	FROM Pagamenti P
	WHERE P.BollettaID = bolletta ORDER BY P.NomeCoinquilino
	;
END;//
DELIMITER ;


DELIMITER //
-- Fa pagare la quota di un coinquilino
CREATE PROCEDURE pagamentoQuota (coinquilino VARCHAR(32), bollettaID INT)
BEGIN
	UPDATE Pagamenti P
	INNER JOIN Bollette B ON B.BollettaID = P.BollettaID
	SET P.DataPagamento = CURDATE()
	WHERE B.BollettaID = bollettaID AND P.NomeCoinquilino = coinquilino
	;
END; //
DELIMITER ;


DELIMITER //
-- Segna che la bolletta è stata pagata
CREATE PROCEDURE pagamentoBolletta (bollettaID INT)
BEGIN
	UPDATE Bollette
	SET DataPagamento = CURDATE()
	WHERE BollettaID = bollettaID
	;
END; //
DELIMITER ;
