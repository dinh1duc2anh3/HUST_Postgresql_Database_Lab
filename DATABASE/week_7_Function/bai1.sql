--Given a classID, write a function, named : number_of_students, that calculates the number of students in this class.
CREATE OR REPLACE FUNCTION number_of_students(classid char) 
returns int as

$$
DECLARE
	students_number int;
BEGIN
	select count(s.student_id) into students_number
	from student s
	where s.clazz_id = classid
	
	return students_number;
end;

$$
LANGUAGE plpgsql;


