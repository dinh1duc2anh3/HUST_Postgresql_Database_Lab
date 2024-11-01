--TAO VIEW

create or replace view student_class_shortinfos AS
select student_id, last_name, first_name ,gender, dob, name
from student s
join clazz c on s.clazz_id = c.clazz_id;





--XEM TABLE/ VIEW

--xem view student_class_shortinfos
SELECT *
FROM student_class_shortinfos
order by student_id;

--xem bang student
select *
from student
-- order by student_id
order by clazz_id

--xem bang clazz
select *
from clazz
order by clazz_id





--TRIGGER FUNCTION + TRIGGER

--tao trigger function cua trigger insert_student_view
create or replace function insert_view_student_class_shortinfos()
returns trigger as
$$
declare
	insert_clazz_id char(10);
begin
	
	select clazz_id into insert_clazz_id
	from clazz c
	where c.name = new.name;
	
	insert into student(student_id, last_name, first_name, gender, dob,clazz_id)	
	values (new.student_id, new.last_name, new.first_name, new.gender, new.dob, insert_clazz_id );
	
	return new;
	
end;
$$
language plpgsql;

--tao trigger de them thong tin vao view : insert_student_view
create trigger insert_student_view
instead of insert on student_class_shortinfos
for each row
execute procedure insert_view_student_class_shortinfos();


--