create database sailors2;
use sailors2;

create table sailors (sid int primary key,sname varchar(100),rating int,age int);
create table boat (bid int primary key,bname varchar(100),color varchar(100));
create table reserves (sid int,bid int, rdate date,foreign key (sid) references sailors(sid),foreign key (bid) references boat(bid));

insert into sailors values (1,"Albert",9,30),(2,"Bose",7,40),(3,"Charles",5,45),(4,"David",7,45),(5,"Medini",8,30);
insert into boat values (1,"astorm","blue"),(2,"brainstorm","white"),(3,"voyage","black"),(4,"pirates","pink"),(5,"sail","yellow");
insert into reserves values (1,1,"2022-3-10"),(2,1,"2022-3-10"),(3,1,"2022-3-10"),(1,2,"2022-3-10"),(1,3,"2022-3-10"),(2,2,"2022-3-10"),(3,4,"2022-3-10"),(4,3,"2022-3-10"),(4,4,"2022-3-10"),
(5,5,"2022-3-10");

select * from sailors;
select * from boat;
select * from reserves;

#Find the colors of boats reserved by Albert

select color 
from boat as b,sailors as s,reserves as r
where b.bid=r.bid and s.sid=r.sid and s.sname="Albert";

#2.	Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 3

select sid from sailors where rating>=8
union
select sid from reserves where bid=3;

#3.	Find the names of sailors who have not reserved a boat whose name contains the string “storm”. Order the names in ascending order.

select sname from sailors
where sid not in(select sid from reserves where bid in(select bid from boat where bname like "%storm%"))
order by sname asc;

#4.	Find the names of sailors who have reserved all boats.
insert into reserves values (1,1,"2023-1-1"),(1,4,"2020-10-10"),(1,5,"2020-10-19");
select sname from sailors
 where not exists (select bid from boat where not exists
 (select bid from reserves where sailors.sid=reserves.sid and boat.bid=reserves.bid));
 
 #5.	Find the name and age of the oldest sailor.
 
select sname,age from sailors
where age in (select max(age) from sailors);

#6	For each boat which was reserved by at least 5 sailors with age >= 40, find the boat id and the average age of such sailors.

select b.bid, avg(age)
from boat b,sailors s,reserves r
where r.sid=s.sid and b.bid=r.bid and s.age>=40
group by b.bid
having count(b.bid)>=2;

#7.	A view that shows names and ratings of all sailors sorted by rating in descending order. 

create view sailors_rating as 
select sname, rating
from sailors
order by rating desc;

#8.	Create a view that shows the names of the sailors who have reserved a boat on a given date.

create view reserved_date as
select sname
from sailors s, reserves r
where s.sid=r.sid and r.rdate="2022-3-10";

#9.	Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.

create view reserved_7 as
select bname,color
from boat b,sailors s,reserves r 
where b.bid=r.bid and s.sid=r.sid and s.rating=7;

#10.	A trigger that prevents boats from being deleted If they have active reservations. 

DELIMITER //
CREATE TRIGGER prevent_boat_deletion 
BEFORE delete ON boat
FOR EACH ROW
BEGIN
    IF (select count(*) from reserves where bid=old.bid>0)
    THEN
        SIGNAL SQLSTATE '14000'
        SET message_text = 'Cannot delete boat with active resevations';
    END IF;
END;
//

delete from boat where bid=1;
#11.	A trigger that prevents sailors with rating less than 3 from reserving a boat.
drop trigger prevent_reservation;
delimiter //
create trigger prevent_reservation
before insert on reserves
for each row
begin
	if ((select rating from sailors where sid=new.sid) < 3)
    then
    signal sqlstate '45000'
    set message_text ="Sailors with rating less than 3 cant reserve boats";
    end if;
    end;
//

insert into sailors values (6,"A",2,10);
insert into reserves values (6,2,"2023-10-10");


#12.	A trigger that deletes all expired reservations.

delimiter //
create trigger delete_expired 
after insert on reserves
for each row
begin 
 delete from reserves where rdate<CURRENT_DATE;
 end;
 //
 
 insert into reserves values (4,3,"2022-1-1");




