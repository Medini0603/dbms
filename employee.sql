create database employee;
use employee;

create table department (dno int primary key,dname varchar(10),mgrssn int,mgrstart date);
#create table department (dno int,dname varchar(10),mgrssn int,mgrstart date,foreign key(mgrssn) references employeee);
create table employee(ssn int primary key,name varchar(100),address varchar(100),sex varchar(10),salary int,superssn int,dno int,
foreign key (dno) references department (dno));

 ALTER TABLE employee
 RENAME COLUMN name to ename;

create table dlocation(dno int,dloc varchar(10));
create table project(pno int primary key,pname varchar(20),ploc varchar(10),dno int,foreign key (dno) references department (dno));
create table workson(ssn int,pno int,hours int,foreign key (ssn) references employee(ssn),foreign key (pno) references project(pno));

insert into department values(1,"Computer","1","2023-1-1"),(2,"Accounts",1,"2023-1-1"),(3,"Electrical",1,"2023-1-1"),
(4,"Marketting",1,"2023-1-1"),(5,"Mechanical",1,"2023-1-1");
update department set mgrssn=3 where dno=5;
insert into employee values(1,"Medini","Mysuru","F",1000000,1,1),(2,"Aishwarya","Mysuru","F",200000,1,2),
(3,"Nisha","Mysuru","F",200000,1,1),(4,"Gouthami","Mysuru","F",200000,1,3),(5,"Varshitha","Mysuru","F",200000,1,4),
(6,"Brunda","Mysuru","F",200000,1,5);
insert into dlocation values (1,"Mysuru"), (2,"Mysuru"), (3,"Mysuru"), (4,"Mysuru"), (5,"Mysuru"), (1,"Banglore");
insert into project values (1,"web dev","Mysuru",1),(2,"ML","Mysuru",1),(3,"Salary","Mysuru",2),(4,"Product invent","Mysuru",2),
(5,"Iot","Mysuru",3),(6,"Advertise","Mysuru",4),(7,"Products","Mysuru",5);
insert into workson values(1,1,10),(1,2,10),(3,1,10),(2,3,1),(4,5,10),(5,6,5),(6,7,10);

#1.	Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’, either as a worker or as a manager of the department that controls the project.
select p.pno from workson w,employee e,project p where e.ssn=w.ssn and p.pno=w.pno and e.ename LIKE "%ini"
union
select pno from project where dno in(select dno from department where mgrssn in(select ssn from employee where ename like "%ini"));
#2.	Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise. 

select salary,salary*1.1 as new_salary
from employee e,project p,workson w
where e.ssn=w.ssn and p.pno=w.pno and p.pname="Iot";
#3.	Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department 
insert into employee values(7,"Radhika","Mysuru","F",100000,1,2),(8,"Sannidhi","Mysuru","F",20000,1,2),
(9,"Sham","Mysuru","F",2000,1,2);
select sum(salary),max(salary),min(salary),avg(salary)
from employee e , department d
where e.dno=d.dno and d.dname="Accounts";
#4.	Retrieve the name of each employee who works on all the projects controlled by department number 1 (use NOT EXISTS operator).

#insert into project values (8,"circuits","Mysuru",3);
#select ename from employee where not exists(select * from project where dno=3 and not exists
#(select * from workson where project.pno=workson.pno and employee.ssn=workson.ssn));
select ename from employee where not exists(select * from project where dno=1 and not exists
(select * from workson where project.pno=workson.pno and employee.ssn=workson.ssn));

#5.	For each department that has more than five employees, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000.

insert into employee values(10,"a","Mysuru","F",100000,1,1),(11,"b","Mysuru","F",20000,1,1),
(12,"c","Mysuru","F",2000,1,1);
insert into employee values(13,"d","Mysuru","F",100000,1,2);
-- select d.dno,count(e.ssn)
-- from department d,employee e
-- where d.dno=e.dno and e.salary>=10000
-- group by d.dno
-- having count(e.ssn)>=5;

select dno,count(*)
from employee
where salary>100000 and dno in
(select dno from employee group by dno having count(*)>=5)
group by dno;


#6.	Create a view that shows name, dept name and location of all employees. 
create view emp_details as
select e.ename,d.dname,dl.dloc
from employee e,department d, dlocation dl
where d.dno=e.dno and d.dno=dl.dno;
#7.	Create a view that shows project name, location and dept.
create view project_info as
select pname,ploc,dno
from project;
#view to show employee and their manager information
drop view emp_manager;
create view emp_manager as
select e.ename as employeename,m.ename as mgrname
from employee as e,employee as m
where e.superssn=m.ssn;

create view emp_dept_manager as
select e.ename as employee,m.ename as magrname,d.mgrstart
from employee as e,employee as m,department d
where e.dno=d.dno and d.mgrssn=m.ssn;
#8.	A trigger that automatically updates manager’s start date when he is assigned . 

drop trigger managerupdate;
delimiter //
create trigger managerupdate
after update on department
for each row
begin
update department
set mgrstart=current_date()
where dno=new.dno and mgrssn=new.mgrssn;
end;
//

update department set mgrssn=2 where dno=3;
#9.	Create a trigger that prevents a project from being deleted if it is currently being worked by any employee.
delimiter //
create trigger prevent_delete
before delete on project
for each row
begin
if((select count(*) from workson where pno=old.pno)>0)
then
signal sqlstate '45000' set message_text="Cant delete project";
end if;
end;
//

delete from project where pno=1;