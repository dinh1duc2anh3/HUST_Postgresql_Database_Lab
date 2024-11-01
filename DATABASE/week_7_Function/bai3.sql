--Create a new table to store GPA (float), CPA (float) of students in each semester
CREATE TABLE student_results (
    student_id char(10),
    semester char(10),
    GPA FLOAT,
    CPA FLOAT,
    primary key (student_id , semester)
);

INSERT INTO student_results (student_id, semester, GPA) VALUES
    ('20225782', '2021A', 3.5),
    ('20225782', '2021B', 3.6),

    ('20220002', '2021A', 3.8),
    ('20220002', '2021B', 3.7),

    ('20160001', '2021A', 2.9),
    ('20160001', '2021B', 3.0);
    
    

--Define a function to update GPA, GPA of a student in a semester.
CREATE OR REPLACE FUNCTION updateGPA_student( update_studentid CHAR(10), update_semester CHAR(10))
RETURNS VOID AS
$$
DECLARE 
    update_cpa FLOAT;
BEGIN

    
        -- Tính CPA bằng cách lấy tổng GPA chia cho số học kỳ
        SELECT SUM(GPA) / COUNT(semester)
        INTO update_cpa
        FROM student_results
        WHERE student_id = update_studentid and semester <= update_semester ;

        -- Cập nhật giá trị CPA trong bảng student_results cho học kỳ cụ thể
        UPDATE student_results
        SET CPA = update_cpa
        WHERE student_id = update_studentid AND semester = update_semester;
    
END;
$$
LANGUAGE plpgsql;




--Define a function to update GPA, GPA for all students in the semester
CREATE OR REPLACE FUNCTION updateGPA( update_semester CHAR(10))
RETURNS VOID AS
$$
DECLARE 
    update_studentid char(10);
    update_cpa FLOAT;
BEGIN
    for update_studentid in (select student_id
                            from student_results)
    LOOP
        -- Tính CPA bằng cách lấy tổng GPA chia cho số học kỳ
        SELECT SUM(GPA) / COUNT(semester)
        INTO update_cpa
        FROM student_results
        WHERE student_id = update_studentid and semester <= update_semester ;

        -- Cập nhật giá trị CPA trong bảng student_results cho học kỳ cụ thể
        UPDATE student_results
        SET CPA = update_cpa
        WHERE student_id = update_studentid AND semester = update_semester;
    end LOOP;
    
        
    
END;
$$


LANGUAGE plpgsql;
