--trigger của bài 2

--When a new student arrives (a new record is inserted into student table), the 
--number of students in her/his class must be automatically updated

------------------------------------------------------------------------------

-- TAO TRIGGER KHI THEM 1 STUDENT VAO BANG STUDENT THI TU DONG UPDATE STUDENT_NUMBER TRONG CLAZZ

create or replace function tf_af_insert()
returns trigger as
$$
begin
	update clazz
	set number_students= number_students +1
	where clazz_id = new.clazz_id;
	return new;
end;
$$
language plpgsql;

create or replace trigger af_insert
after insert on student
for each row
when (new.clazz_id is not null)
execute procedure tf_af_insert();


--them thong tin vao view student_class_shortinfos
INSERT INTO student_class_shortinfos (student_id, last_name, first_name, gender, dob, name)
VALUES ( '20160006' , 'Van', 'Anh', 'F','2000-03-02','CNTT1.01-K61'); 

------------------------------------------------------------------------------


--TAO TRIGGER KHI XOA MOT SINH VIEN DE TU DONG CAP NHAT NUMBER_STUDENT

create or replace function tf_df_delete()
returns trigger as
$$
begin
	update clazz
	set number_students = number_students - 1
	where clazz_id = old.clazz_id;
	return OLD;
	
end;
$$
language plpgsql;

create or replace trigger df_delete
after delete on student
for each row
when (old.clazz_id is not null)
execute procedure tf_df_delete();

--DELETE STUDENT QUERY
delete from student
where student_id = '20160005'


------------------------------------------------------------------------------


--TAO TRIGGER KHI THAY DOI LOP MOT SINH VIEN DE TU DONG CAP NHAT NUMBER_STUDENT

create or replace function tf_cf_change()
returns trigger as
$$
begin
	update clazz
	set number_students = number_students -1 
	where clazz_id = old.clazz_id;
	
	update clazz
	set number_students = number_students + 1 
	where clazz_id = new.clazz_id;
	return new;
end;
$$
language plpgsql;

create or replace trigger cf_change
after update on student 
for each row
when (new.clazz_id is not null 
	  and old.clazz_id is distinct from new.clazz_id)
execute procedure tf_cf_change();

--UPDATE STUDENT'S CLASS 
UPDATE student
SET clazz_id = '20162101'
WHERE student_id = '20160007';

------------------------------------------------------------------------------

-- TAO TRIGGER DE GIOI HAN SO LUONG SINH VIEN DANG KI

create or replace function check_enrollment_limit()
returns trigger as
$$
declare 
    current_count int;
begin
    SELECT count(*) into current_count
            from enrollment
            where subject_id = new.subject_id
            and semester = new.semester
    if current_count >= 200 THEN
            raise EXCEPTION 'enrollment reach limit for this subject in this semester';
    end if;
    
    return new;
end;
$$ language plpgsql;


create trigger enrollment_limit_trigger
before insert or update on enrollment
for each row
execute procedure check_enrollment_limit();
