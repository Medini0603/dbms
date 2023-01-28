create database student;
use student;

create table student(regno int primary key,sname varchar(100),bdate date);
create table course(cid int primary key,cname varchar(100),dept varchar(100));
create table enroll(regno int,cid int,sem int,mark int,foreign key (regno) references student(regno) on delete cascade,
foreign key (cid) references course (cid));
create table textbook(tid int primary key,bname varchar(100),publ varchar(100),author varchar(10));
create table bookadopt(cid int,tid int,sem int,
foreign key (cid) references course(cid),foreign key (tid) references textbook(tid));

insert into student values(1,"Medini","2002-6-3"),(2,"Aishwarya","2002-4-14"),(3,"Nisha","2002-4-22"),
(4,"Varshitha","2002-10-23"),(5,"Gouthami","2003-1-1");
insert into course values(1,"OOPs","CS"),(2,"DS","CS"),(3,"DBMS","CS"),
(4,"MAth","MA"),(5,"IOt","EC"),(6,"Ckt","EC");
insert into enroll values(1,1,3,100),(1,2,3,99),(1,3,5,95),(2,1,3,90),(2,2,3,100),(2,3,5,85),
(3,1,3,90),(3,2,3,85),(3,3,5,100),(4,5,5,100),(5,4,5,90),(5,6,5,100);
insert into textbook values(1,"dsada","P1","A"),(2,"ADA in c","P1","B"),(3,"oops","P2","A"),(4,"java oops","P2","C"),
(5,"Dbms fundamentals","P1","A"),(6,"DBMS BAsic","P1","C"),(7,"Integrals","P5","D"),(8,"iot basic","P9","a"),
(9,"Basics of ckt","P9","b"),(10,"IOt joy","P(","c");
update textbook set publ="P9" where tid=10;
insert into bookadopt values(2,1,3),(2,2,3),(1,3,3),(1,4,3),(3,5,5),(3,6,5),(4,7,5),(5,8,5),(6,9,5),(5,10,5);

#1.	Demonstrate how you add a new text book to the database and make this book be adopted by some department. 
insert into textbook values(11,"MAthss","P1","a");
insert into bookadopt values (4,11,5);
#2.	Produce a list of text books (include Course #, Book-ISBN, Book-title)
# in the alphabetical order for courses offered by the ‘CS’ department that use more than one books. 

insert into textbook values(12,"oops in cpp","P1","a");
insert into bookadopt values (1,12,3);
select c.cid,t.tid,bname
from course c,textbook t,bookadopt b
where c.dept="CS" and c.cid=b.cid and t.tid=b.tid and c.cid in
(select cid from bookadopt group by cid having count(*)>2)
order by bname;

#3.	List any department that has all its adopted books published by a specific publisher.
#let P9
select c.dept 
from course c,bookadopt b,textbook t
where t.publ="P9" and c.cid=b.cid and t.tid=b.tid
group by c.dept
having count(distinct t.tid)=(select count(*) from bookadopt b1 where b1.cid in(select cid from course where dept=c.dept));

-- select dept 
-- from course where not exists (select * from course c,bookadopt b,textbook t where c.cid=b.cid and b.tid=t.tid and 
-- not exists(select * from course c,bookadopt b,textbook t where c.cid=b.cid and b.tid=t.tid and t.publ="P9") group by c.dept)

#4.	List the students who have scored maximum marks in ‘DBMS’ course.
select sname from student s,enroll e,course c
where e.regno=s.regno and c.cid=e.cid and c.cname="DBMS" and e.mark in (select max(mark) from enroll e where e.cid=c.cid);

#5.	Create a view to display all the courses opted by a student along with marks obtained.

create view marks_sheet as
select s.sname,c.cname,e.mark
from student s,course c,enroll e
where s.regno=e.regno and c.cid=e.cid;

select * from marks_sheet;

#6.	Create a view to show the enrolled details of a student.
drop view enroll_details;
create view enroll_details as
select s.sname,s.regno,bdate,e.sem ,e.cid
from student s,enroll e
where s.regno=e.regno;
#7.	Create a view to display course related books from course_adoption and text book table using book_ISBN. 
create view course_books as
select c.cid,c.cname,t.bname
from textbook t,course c,bookadopt ba
where ba.tid=t.tid and c.cid=ba.cid;

#enrollment details of courses enrolled
drop view course_enroll;
create view course_enroll as
select c.cid,cname,dept,count(regno) as totalenrolled
from course c,enroll e
where c.cid=e.cid
group by c.cid;
#8.	Create a trigger such that it Deletes all records from enroll table when course is deleted . 
drop trigger delete_enrollment;
delimiter //
create trigger delete_enrollment
after delete on course
for each row
begin
delete from enroll where cid=old.cid;
end;
//
SET foreign_key_checks = 0;
delete from course where cid=6;
SET foreign_key_checks = 1;

#9.	Create a trigger that prevents a student from enrolling in a course if the marks pre_requisit is less than the given threshold . 

delimiter //
create trigger prevent_enroll
before insert on enroll
for each row
begin
declare prereqcourse int;
declare prereqmarks int;
select cid into prereqcourse from course where cid=new.cid;
select mark into prereqmarks from enroll where regno=new.regno and cid=prereqcourse;
if prereqmarks<90 then
signal sqlstate '45000' set message_text="cannot enroll";
end if;
end;
//

insert into enroll values(2,3,5,90);
insert into enroll values(1,1,3,40);
