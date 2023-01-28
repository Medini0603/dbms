create database insurance2;
use insurance2;

create table person(pid int primary key,pname varchar(100),address varchar(100));
create table car(regno int primary key,model varchar(100),year int);
create table accident(aid int primary key,accdate date,loc varchar(10));
create table owns(pid int,regno int,foreign key(pid) references person(pid),foreign key (regno) references car(regno));
drop table participated;
create table participated(pid int,regno int,aid int,damage int,
foreign key (pid) references person(pid),foreign key (aid) references accident(aid),foreign key (regno) references car(regno));

insert into person values(1,"Smith","Mysuru"),(2,"Albert","Udupi"),(3,"Medini","Hassan"),(4,"John","Goa"),(5,"Charles","manglore");
insert into car values(1,"Mazda",2000),(2,"Wagonar",2002),(3,"Swift",2004),(4,"Duster",2006),(5,"Nano",2020);
insert into accident values(1,"2021-10-10","Mysuru"),(2,"2022-10-10","Goa"),(3,"2021-10-10","Udupi"),(4,"2023-1-1","Manglore"),(5,"2021-1-1","Goa"),
(6,"2022-1-1","Delhi"),(7,"2020-1-1","Mysuru"),(8,"2021-1-12","Hassan");
insert into owns values(1,1),(2,2),(3,3),(4,4),(5,5);
insert into participated values(1,1,1,100000),(2,2,2,200000),(3,3,3,30000),(4,4,4,100000),(5,5,5,20000),(1,1,6,1234),(2,2,7,2453),(3,3,8,12234);

#1.	Find the total number of people who owned cars that were involved in accidents in 2021.

select count(p.pid) from person p,owns o,car c,participated pa,accident a
where p.pid=o.pid and p.pid=pa.pid and c.regno=o.regno and a.aid=pa.aid and c.regno=pa.regno and year(a.accdate)="2021";

#2.	Find the number of accidents in which the cars belonging to “Smith” were involved. 

select count(*) from person p,owns o,car c,participated pa,accident a
where p.pid=o.pid and o.regno=c.regno and a.aid=pa.aid and p.pid=pa.pid and c.regno=pa.regno and pname="Smith";

#3	Add a new accident to the database; assume any values for required attributes.

insert into accident values (9,"2022-10-10","Goa");
insert into participated values (4,4,9,1234);

#4.	Delete the Mazda belonging to “Smith”. 

delete from owns where pid in (select pid from person where pname="Smith") and regno in(select regno from car where model="Mazda");
select * from owns;

#5.	Update the damage amount for the car with license number “KA09MA1234” in the accident with report

update participated set damage=155555 where aid=1 and regno=1;
select * from participated;

#6.	A view that shows models and year of cars that are involved in accident. 
alter table car rename column year to ayear; 
create view car_accident as
select model,ayear
from car c,participated pa 
where c.regno=pa.regno;
#7.	Create a view that shows name and address of drivers who own a car.
create view owner_car as
select pname, address
from person p,owns o
where p.pid=o.pid;
#8.	Create a view that shows the names of the drivers who a participated in a accident in a specific place.
create view driver_acc as
select pname from person p,participated pa , accident a
where p.pid=pa.pid and a.aid=pa.aid and loc="Mysuru";
#view to show damage amt of each driver
create view damage_amt_driver as
select pname,sum(damage) as total_Amt
from participated pa,person p
where pa.pid=p.pid
group by pname;
#9.	A trigger that prevents driver with total damage amount >rs.50,000 from owning a car. 
delimiter //
create trigger prevent_own
before insert on owns
for each row
begin
if((select sum(damage) from participated where pid=new.pid)>50000)
then signal sqlstate "45000" set message_text="You cant own a car ";
end if;
end;
//

insert into owns values(1,3);
#10.	A trigger that prevents a driver from participating in more than 3 accidents in a given year.
drop trigger prevent_acc;
delimiter //
create trigger prevent_acc
before insert on participated
for each row
begin
if((select count(*) from participated,accident where pid=new.pid and accident.aid=participated.aid and YEAR(accdate)=YEAR(CURRENT_DATE))>=3)
then
signal sqlstate '45000' set message_text="CAnt particiapte";
end if;
end;
//

insert into accident values (10,"2023-1-1","Goa"), (11,"2023-1-1","Goa") ,(12,"2023-1-1","Goa");
insert into participated values (1,1,10,100000),(1,1,11,100000),(1,1,12,100000);
insert into participated values (1,1,9,123);