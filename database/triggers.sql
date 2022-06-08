delimiter |

CREATE TRIGGER setAmount
AFTER INSERT
ON Bollette for each row
BEGIN
	INSERT INTO Pagamenti (BollettaID, NomeCoinquilino, Importo)
	SELECT B.BollettaID, C.Nome, B.ImportoTotale / 5 as Importo
	FROM Coinquilini C, Bollette B
    WHERE B.BollettaID NOT IN 
                    (SELECT P.BollettaID
					FROM Pagamenti P
					)
    ;
END;
|

DROP TRIGGER setAmount;

