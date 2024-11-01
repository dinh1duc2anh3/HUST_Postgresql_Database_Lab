--Add a new attribute (named: number_students, data type: integer) on clazz table to store number of students in class.
ALTER TABLE clazz add column number_students int;

--Define a function (named update_number_students()) that computes the number of students for each class and update the correct value for number_students attribute
CREATE OR REPLACE FUNCTION update_number_students()
returns void as  
$$
DECLARE
    class_id char(10);
	student_count int;
BEGIN
    for class_id in ( select clazz_id from clazz )
    LOOP
        select number_of_students(class_id) into student_count;

        update clazz 
        set number_students = student_count
        where clazz_id = class_id;
    END LOOP;
END;

$$
LANGUAGE plpgsql;


