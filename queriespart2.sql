
--  Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a certain return period). Display the member's name, book title, issue date, and days overdue.

set sql_safe_updates=0;
update issued_status
set issued_date=issued_date+interval 2 year;
update return_status
set return_date=return_date+interval 2 year;
select i.issued_book_name,m.member_name,i.issued_id,i.issued_date,rs.return_date,datediff(current_date,i.issued_date) as daysoverdue
from issued_status as i
left join return_status as rs
on i.issued_id=rs.issued_id
left join members as m
on i.issued_member_id=m.member_id
where  return_date IS NULL and datediff(current_date,i.issued_date)>60;



-- Task 14: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

select b.branch_address,count(i.issued_id) as total_issued,count(rs.return_id)as total_returned,sum(books.rental_price)as total_rental_price from
issued_status as i join employees as e
on i.issued_emp_id=e.emp_id
join branch as b
on b.branch_id=e.branch_id
join books 
on books.isbn=i.issued_book_isbn
left join return_status as rs
on rs.issued_id=i.issued_id
group by 1;


-- Task 15: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last x months.

create table active_members
as
select * from members
where member_id IN (select distinct member_id from issued_status
                     where issued_date>=current_date()-interval 25 month);
select * from active_members;

-- Task 16: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

with top as
(select issued_emp_id,count(*) as number_of_books  from issued_status
group by 1)
select e.emp_name,t.number_of_books,b.branch_address
from top as t
join employees as e
on t.issued_emp_id=e.emp_id
join branch as b
on b.branch_id=e.branch_id
order by 2 desc;


-- Task 17: Create Table As Select (CTAS)
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 60 days. The table should include:
--    The total fines, with each day's fine calculated at $0.50.
--    The number of books issued by each member.
--    The resulting table should show:
 --   Member ID
 --   Number of overdue books
 
 create table fines as
 select m.member_id,m.member_name,datediff(current_date - interval 60 day,i.issued_date) as overdue from issued_status as i
 join members as m
 on i.issued_member_id=m.member_id
 left join return_status as rs
 on rs.issued_id=i.issued_id
 where  rs.return_date is null and  datediff(current_date,i.issued_date)>60;
 
 select * from fines;
 
 select  member_id,member_name,count(*),sum(overdue),sum(overdue)*0.5 as fine_indollars
 from fines
 group by 1,2;


 
 
 
 
 
 
