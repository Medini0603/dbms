create database orders;
use orders;

create table customer(cid int primary key,cname varchar(21),city varchar(20));
create table orders(oid int primary key,odate date,cid int,oamt int,foreign key (cid) references customer(cid));
create table item(id int primary key,price int);
create table warehouse(wid int primary key,city varchar(20));
#drop table orderitem;
create table orderitem (oid int, id int, qty int,foreign key (oid) references orders (oid) on delete cascade, foreign key (id) references item (id) on delete cascade);
#drop table shipment;
create table shipment (oid int,wid int, shipdate date,
foreign key (oid) references orders (oid) on delete cascade, foreign key (wid) references warehouse (wid) on delete cascade);

insert into customer values (1,"Kumar","Mysuru"),(2,"Medini","Udupi"),(3,"Sannidhi","Delhi"),(4,"Shyam","Hassan"),(5,"Radhika","Kundapur");
insert into orders values(1,"2020-12-12",1,1000),(2,"2021-1-1",1,1234),(3,"2022-3-3",2,124),(4,"2022-2-2",2,123425),(5,"2023-1-1",3,234),
(6,"2023-4-4",4,12324),(7,"2022-12-13",5,234);
insert into item values(1,12),(2,23),(3,234),(4,42),(5,24);
insert into orderitem values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,1,2),(7,2,4);
insert into warehouse values(1,"Mysuru"),(2,"Delhi"),(3,"Udupi"),(4,"Hassan"),(5,"Kundapur");
insert into shipment values (1,1,"2023-1-1"),(2,2,"2023-1-1"),(3,3,"2023-1-1"),(4,4,"2023-1-1"),(5,5,"2023-1-1"),
(6,1,"2023-4-4"),(7,2,"2023-1-1");

#1.	List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
select oid , shipdate 
from shipment
where wid=2;

#2.	List the Warehouse information from which the Customer named "Kumar" was supplied his orders.
# Produce a listing of Order#, Warehouse#
select s.oid,wid 
from shipment s,customer c,orders o
where s.oid=o.oid and c.cid=o.cid and c.cname="Kumar";

#3.	Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer 
#and the last column is the average order amount for that customer. (Use aggregate functions)

select c.cname,count(*),avg(oamt)
from customer c,orders o
where c.cid=o.cid 
group by c.cname;

#4.	Delete all orders for customer named "Kumar".
delete from orders where cid in (select cid from customer where cname="Kumar");
select * from orders;

#5.	Find the item with the maximum unit price.
select * from item
where price in (select max(price) from item);

#1.create view to	List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
create view warehouse2 as
select oid , shipdate 
from shipment
where wid=2;

#2create view to List the Warehouse information from which the Customer named "Kumar" was supplied his orders.
# Produce a listing of Order#, Warehouse#

create view kumar_ship as
select s.oid,wid 
from shipment s,customer c,orders o
where s.oid=o.oid and c.cid=o.cid and c.cname="Kumar";

#3.create view Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer 
#and the last column is the average order amount for that customer

create view list_of_orders as
select c.cname,count(*),avg(oamt)
from customer c,orders o
where c.cid=o.cid 
group by c.cname;

#9.	A tigger that updates order_amount based on quantity and unit price of order_item .
drop trigger update_amt;
delimiter //
create trigger update_amt
after update on orderitem 
for each row
begin
update orders o
set o.oamt=(select sum(oi.qty*i.price) 
		   from orderitem oi,item i
           where oi.id=i.id)
where o.oid=new.oid;
end;
//

update orderitem set qty=10 where oid=3 and id=3;

#10 a trigger that prevents orders with total greater than rs 10000 from being placed
drop trigger prevent_order;
delimiter //
create trigger prevent_order
before insert on palced
for each row
begin
if((select sum(oi.qty*i.price) 
		   from orderitem oi,item i
           where oi.id=i.id and oi.oid=new.oid )>1000)
then 
signal sqlstate '45000' set message_text="cant palce order";
end if;
end;
//

create table palced (oid int, foreign key (oid) references orders(oid));
insert into orders values(1,"2023-1-1",2,123);
insert into orderitem values(1,3,3);
insert into palced values(1);