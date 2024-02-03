use zomato 
create table users(userid integer,signup_date date);

insert into users (userid,signup_date) 
VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

select * from users 

create table goldusers_signup(userid integer,signup_date date);

insert into goldusers_signup(userid,signup_date) 
VALUES (1,'09-22-2017'),
(3,'04-21-2017');

select * from goldusers_signup

create table sales (userid integer,created_date date,product_id integer) 

insert into sales (userid,created_date,product_id )
values (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3); 

select * from sales 

create table product (product_id integer,product_name text,price integer) 

insert into product (product_id,product_name,price )
values (1,'p1',980),
(2,'p2',870),
(3,'p3',330) ;

select * from product   
select * from sales 
select * from goldusers_signup  
select * from users 

--1. What is the total amount each customers spent on zomato 

select sum(p.price), s.userid from product as p  
inner join sales as s 
on p.product_id = s.product_id  
group by userid 

--2 How many days has each customers visited Zomato 

select count (created_date) , userid from sales 
group by userid 

--3 what was the first product purchase by each customers 

select * from (select *  , 
rank () over (partition by userid order by created_date) as "ranking" from sales )
a where ranking = 1  

--4 what is the  most purchased item in the menu and how may times it has been purchased 

select userid, count (product_id) from sales where product_id = 
(select  top 1 sa.product_id,  count (sa.product_id) from sales as sa 
group by sa.product_id
order by Count (sa.product_id) desc) 
group by userid

--5 which item was the most poppular for each customers 

select * from (
select * , rank () over (partition by b.userid order by b.cnt desc ) rnk from sales where product_id = (
Select userid , product_id, count (product_id) cnt from sales 
group by userid, product_id )) b
where rnk = 1 

--6. which item was first purchased by the customer after they become member 

select * from  (
select c.*, rank () over (partition by userid order by c.created_date ) rnk from  ( 
select gs.userid , s.product_id , gs.signup_date, s.created_date 
from goldusers_signup as gs 
left join sales as s 
on gs.userid = s.userid and gs.signup_date < s.created_date  ) c ) d where rnk = 1 

--7. Which item was purchased by the customer before they become member 

select * from  (
select c.*, rank () over (partition by userid order by c.created_date ) rnk from  ( 
select gs.userid , s.product_id , gs.signup_date, s.created_date 
from goldusers_signup as gs 
inner join sales as s 
on gs.userid = s.userid and gs.signup_date > s.created_date ) c ) d where rnk = 1 

--8 What is the total orders and amount spent for each member before they become a member

select s.userid , count(s.userid) as "total order" , sum (p.price) as "Total amount" 
from goldusers_signup as gs 
inner join sales as s 
on s.userid = gs.userid and s.created_date < gs.signup_date 
inner join product as p 
on s.product_id = p.product_id 
group by s.userid 

--9 Rank all the transections of the customers 

select * , 
rank () over (partition by userid order by created_date ) as "Transection "
from sales 

--10 Those customers who are gold customers write yes their and those who are not write no 

select *  ,
case 
      when gs.signup_date = NULL then 'No' 
	  else 'Yes'
end AS "Golden users"
from users as u
left join goldusers_signup as gs 
on u.userid = gs.userid  
