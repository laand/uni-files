-- Aufgabe 3
insert into Standort
select SSEQ.nextval, 'Hallenbadkreuzung', 'Lichtmast links', 9.655744, 47.828518, GID 
from Gemeinde where GName = 'Baienfurt';

insert into liegt_auf
select SSEQ.currval, RID, 12.1 from Route where RName = 'Schussental';
commit;

-- Aufgabe 4
update liegt_auf set km = km - 5.5 
where Route = (select RID from Route where RName = 'Schussental');
commit;

-- Aufgabe 5
select * from Gemeinde;

-- Aufgabe 6
select RName, Ziel from Route;

-- Aufgabe 7
select Fernziel, kmfern, Nahziel, kmnah
from Wegweiser
where Typ = 'Haupt' and Zustand = 'ok';

-- Aufgabe 8
select Lagebeschreibung
from Standort, Gemeinde
where Standort.Gemeinde = Gemeinde.GID
  and Gemeinde.GName = 'Ravensburg';
  
-- Aufgabe 9
select distinct GName
from Gemeinde g, Standort s, liegt_auf la, Route r
where g.GID = s.Gemeinde and s.StID = la.Standort and la.Route = r.RID
  and r.RName = 'Schussental';
  
-- Aufgabe 10
select w.Pfeilrichtung, w.Zustand, s.Lagebeschreibung, w.Richtung, la.km
from Wegweiser w, Standort s, Route r, liegt_auf la
where w.Standort = s.StID and s.StID = la.Standort and la.Route = r.RID and
 r.RName = 'Schussental' and w.Typ = 'Zwischen'
order by w.Richtung, la.km;

-- Aufgabe 11
select RName, count(WID) AnzahlHauptWegweiser, AVG(kmfern) DurchschnittKmFern, 
       min(kmfern) kürzesteZielangabe, max (kmfern) weitesteZielangabe
from Route, Wegweiser
where Route.RID = Wegweiser.Route and Typ = 'Haupt'
group by RName;

-- Aufgabe 12
select RName, count(WID) AnzahlHauptWegweiser, AVG(kmfern) DurchschnittKmFern, 
       min(kmfern) kürzesteZielangabe, max (kmfern) weitesteZielangabe
from Route, Wegweiser
where Route.RID = Wegweiser.Route and Typ = 'Haupt'
group by RName
having count(WID) > 2;

-- Aufgabe 13
select * from Gemeinde where PLZ like '882%';

-- Aufgabe 14
select * from Route
where Anfang = (select Anfang from Route where RName = 'Schussental');

-- Aufgabe 15
delete from Wegweiser where Route = (select RID from Route where RName = 'Holperroute');
delete from liegt_auf where Route = (select RID from Route where RName = 'Holperroute');
delete from Route where RName = 'Holperroute';
commit;

-- Aufgabe 16
select Fernziel, kmfern, (select max(kmnah) from Wegweiser) MaxKmNah
from Wegweiser
where kmfern < (select max(kmnah) from Wegweiser);

-- Aufgabe 17
select s.*
from Standort s, Wegweiser w
where w.Standort = s.StID 
  and (w.Standort, w.Route) not in (select Standort, Route from liegt_auf);
  
-- Aufgabe 18
Create Table Zwischenwegweiser_Tab
as select WID, Zustand, Richtung, Pfeilrichtung, Standort, Route 
from Wegweiser 
where Typ = 'Zwischen';

create view Zwischenwegweiser_view
as select WID, Zustand, Richtung, Pfeilrichtung, Standort, Route 
from Wegweiser 
where Typ = 'Zwischen';

insert into Wegweiser (WID, Zustand, Richtung, Pfeilrichtung, Typ, Standort, Route)
values (WSEQ.nextval, 'ok', 'hin', 'rechts', 'Zwischen', 1, 1);

select * from Zwischenwegweiser_tab where Standort = 1 and Route = 1;
select * from Zwischenwegweiser_view where Standort = 1 and Route = 1;

drop table Zwischenwegweiser_tab;
rollback;

-- Aufgabe 19
select Zustand, Pfeilrichtung from Zwischenwegweiser_view;

-- Aufgabe 20
alter table Kommentar
add (Bezugzu integer constraint fk_Bezugzu references Kommentar (KID));

update Kommentar set Bezugzu = 3 where KID = 4;
update Kommentar set Bezugzu = 4 where KID = 5;
commit;

select k1.Datum, k1.Text, k2.Datum, k2.Text
from Kommentar k1 left outer join Kommentar k2 on k1.Bezugzu = k2.KID;