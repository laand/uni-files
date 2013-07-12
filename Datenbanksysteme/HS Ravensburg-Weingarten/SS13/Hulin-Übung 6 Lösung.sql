CREATE OR REPLACE
TRIGGER TESTSTANDORTROUTE 
BEFORE INSERT OR UPDATE OF WID,ZUSTAND,RICHTUNG,FERNZIEL,KMFERN,NAHZIEL,KMNAH,PFEILRICHTUNG,TYP,ROUTE ON WEGWEISER 
FOR EACH ROW 
DECLARE
  passt INTEGER;
BEGIN
  SELECT COUNT(*) INTO passt
  FROM LIEGT_AUF
  WHERE ROUTE = :NEW.ROUTE AND STANDORT = :NEW.STANDORT;
  
  IF PASST = 0
  THEN RAISE_APPLICATION_ERROR(-20001, 'Standort des Wegweisers liegt nicht auf seiner Route');
  END IF;
END;
/

CREATE OR REPLACE
TRIGGER ZWISCHENWEGWEISERTRIGGER
INSTEAD OF INSERT ON ZWISCHENWEGWEISERLISTE
FOR EACH ROW
DECLARE
  direction VARCHAR(20);
BEGIN
  direction := :NEW.pfeilrichtung;
  IF(direction IS NULL) THEN
    direction := 'geradeaus';
  END IF;
  INSERT INTO wegweiser (wid, zustand, richtung, pfeilrichtung, typ, standort, route)
  VALUES (:NEW.wid, :NEW.zustand, :NEW.richtung, direction, 'Zwischen', :NEW.standort, :NEW.route);
END;
/

CREATE OR REPLACE
TRIGGER SETKMFERN 
BEFORE INSERT ON Wegweiser
FOR EACH ROW 
DECLARE
 KMFERN NUMBER(5,1); -- kmfern des anderen Wegweisers
 KMVONSTART NUMBER(5,1); -- km vom Routenstart des Standorts des anderen Wegweisers
 Kmvonstartneu NUMBER(5,1); -- km vom Routenstart des Standorts des neuen Wegweisers

-- Cusor für alle anderen Hauptwegweiser auf der gleichen Route des neuen Wegweisers
-- die das gleiche Fernziel haben und in die gleich Fahrtrichtung zeigen
 CURSOR ANDERE_WEGWEISER IS
 SELECT KMFERN, LIEGT_AUF.KM
 FROM WEGWEISER, LIEGT_AUF
 WHERE WEGWEISER.ROUTE = LIEGT_AUF.ROUTE
   AND WEGWEISER.STANDORT = LIEGT_AUF.STANDORT
   AND WEGWEISER.FERNZIEL = :NEW.FERNZIEL
   AND WEGWEISER.RICHTUNG = :NEW.RICHTUNG
   AND KMFERN IS NOT NULL
   AND TYP = 'Haupt';
   
BEGIN
  -- Wie weit ist der Standort des neuen Wegweisers vom Routenstart entfernt?
  -- -> Kmvonstartneu
  SELECT KM INTO KMVONSTARTNEU FROM LIEGT_AUF
  WHERE ROUTE = :NEW.ROUTE AND STANDORT = :NEW.STANDORT;
  
  -- Nur wenn kmfern nicht gesetzt ist, aber der Abstand vom Routenstart
  -- bekannt ist und der Wegweiser Hauptwegweiserist, soll kmfern berechnet werden
  IF :NEW.KMFERN IS NULL AND KMVONSTARTNEU IS NOT NULL AND :NEW.TYP = 'Haupt'
  THEN
   OPEN ANDERE_WEGWEISER;
   LOOP
    FETCH ANDERE_WEGWEISER INTO KMFERN, KMVONSTART;
    EXIT WHEN ANDERE_WEGWEISER%NOTFOUND;
    
    -- Berechne kmfern des neuen Wegweisers aus der Entfernungsangabe eines anderen
    -- Wegweisers mit dem gleichen Fernziel
    :NEW.KMFERN := KMFERN + KMVONSTART - KMVONSTARTNEU;
    
    -- sobald kmfern berechnet wurde, brich ab und führe die Berechnung nicht 
    -- nochmal mit den Daten weiterer Wegweiser aus
    EXIT; 
   END LOOP;
  END IF;
END;
/

