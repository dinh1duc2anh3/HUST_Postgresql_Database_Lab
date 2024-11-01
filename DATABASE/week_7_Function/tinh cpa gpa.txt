CREATE TABLE student_results (
	student_id char(8),
    semester char(5),
    GPA float,
    CPA float,
	PRIMARY KEY (student_id, semester),
    FOREIGN KEY (student_id) REFERENCES student(student_id)
);

CREATE OR REPLACE FUNCTION  updateGPA_student(studentid char(8), p_semester char(5)) 
RETURNS VOID AS $$
BEGIN
    
    UPDATE student_results
    SET GPA = (SELECT SUM(point) / SUM (credit) FROM (
        SELECT (final_score * percentage_final_exam / 100 + midterm_score * (100 - percentage_final_exam) /100 ) * credit 
		as point, credit  
		FROM enrollment 
		JOIN subject 
		ON enrollment.subject_id = subject.subject_id
        WHERE semester = p_semester AND student_id = studentid
    ))
    WHERE student_id = studentid AND student_results.semester = p_semester;

    IF NOT FOUND THEN
        INSERT INTO student_results (student_id, semester, GPA)
        VALUES (studentid, p_semester, (SELECT SUM(point) / SUM (credit) 
		FROM (
        	SELECT (final_score * percentage_final_exam / 100 + midterm_score * (100 - percentage_final_exam) /100 ) * credit 
			as point, credit  
			FROM enrollment 
			JOIN subject ON enrollment.subject_id = subject.subject_id
        	WHERE semester = p_semester AND student_id = studentid
		)
    ));
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION  updateGPA(p_semester char(5)) 
RETURNS VOID AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT student_id
        FROM enrollment
        WHERE semester = p_semester
    LOOP
        PERFORM updateGPA_student(rec.student_id, p_semester);
    END LOOP;

END;
$$ LANGUAGE plpgsql;

--checking
--func 1
--select updateGPA_student('20160001', '20171')
--func 2
--select updateGPA('20171')





