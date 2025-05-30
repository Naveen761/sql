use sql_project;

CREATE TABLE job_applications (
    Applicant_Name VARCHAR(100),
    Experience_of_Applicant INT,
    Skills VARCHAR(255),
    Job_Application_ID VARCHAR(20),
    PRIMARY KEY (Applicant_Name, Job_Application_ID)
);



CREATE TABLE open_positions (
    Project_Name VARCHAR(100),
    Open_Positions VARCHAR(100),
    Key_Skills VARCHAR(255),
    Job_Application_ID VARCHAR(20) PRIMARY KEY
);




CREATE TABLE IF NOT EXISTS job_applications_skills (
    Applicant_Name VARCHAR(50),
    Experience_of_Applicant int,
    Skill VARCHAR(50),
    Job_Application_ID VARCHAR(20),
    PRIMARY KEY (Applicant_Name, Skill, Job_Application_ID),
    FOREIGN KEY (Applicant_Name, Job_Application_ID) 
        REFERENCES job_applications(Applicant_Name, Job_Application_ID) 
        ON DELETE CASCADE
);




DELIMITER $$

CREATE PROCEDURE InsertIntoJobApplicationsSkills()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_Applicant_Name VARCHAR(50);
    DECLARE v_Experience_of_Applicant INT;
    DECLARE v_Skills VARCHAR(150);
    DECLARE v_Job_Application_ID VARCHAR(20);
    DECLARE skill VARCHAR(50);
    DECLARE skill_cursor CURSOR FOR 
        SELECT Applicant_Name, Experience_of_Applicant, Skills, Job_Application_ID 
        FROM job_applications;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN skill_cursor;

    read_loop: LOOP
        FETCH skill_cursor INTO v_Applicant_Name, v_Experience_of_Applicant, v_Skills, v_Job_Application_ID;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Split skills and insert each one separately
        WHILE LENGTH(v_Skills) > 0 DO
            SET skill = SUBSTRING_INDEX(v_Skills, ',', 1);  -- Extract the first skill
            SET v_Skills = IF(LOCATE(',', v_Skills) > 0, SUBSTRING(v_Skills, LOCATE(',', v_Skills) + 1), '');  -- Remove the extracted skill

            -- Insert the record
            INSERT INTO job_applications_skills (Applicant_Name, Experience_of_Applicant, Skill, Job_Application_ID)
            VALUES (v_Applicant_Name, v_Experience_of_Applicant, skill, v_Job_Application_ID);
        END WHILE;
    END LOOP;

    CLOSE skill_cursor;
END$$

DELIMITER ;


CALL InsertIntoJobApplicationsSkills();





-- Create triger job application
DELIMITER $$

CREATE TRIGGER trg_InsertJobApplicationsSkills
AFTER INSERT ON job_applications
FOR EACH ROW
BEGIN
    DECLARE skill VARCHAR(50);
    DECLARE remaining_skills VARCHAR(150);

    SET remaining_skills = NEW.Skills;  -- Get the skills from the inserted row

    -- Loop through each skill in the comma-separated list
    WHILE LENGTH(remaining_skills) > 0 DO
        SET skill = SUBSTRING_INDEX(remaining_skills, ',', 1);  -- Extract first skill
        SET remaining_skills = IF(LOCATE(',', remaining_skills) > 0, 
                                  SUBSTRING(remaining_skills, LOCATE(',', remaining_skills) + 1), 
                                  '');  -- Remove the extracted skill

        -- Insert each skill separately into job_applications_skills
        INSERT INTO job_applications_skills (Applicant_Name, Experience_of_Applicant, Skill, Job_Application_ID)
        VALUES (NEW.Applicant_Name, NEW.Experience_of_Applicant, skill, NEW.Job_Application_ID);
    END WHILE;
END$$

DELIMITER ;


SELECT * FROM job_applications_skills;



INSERT INTO job_applications (Applicant_Name, Experience_of_Applicant, Skills, Job_Application_ID)
VALUES ('John Doe', 5, 'Python,SQL,Power BI', 'J1001');


delete from job_applications
where Applicant_Name='John Doe';



CREATE TABLE IF NOT EXISTS open_positions_skills (
    Project_Name VARCHAR(20),
    Open_Positions VARCHAR(50),
    Skill VARCHAR(50),
    Job_Application_ID VARCHAR(20),
    PRIMARY KEY (Project_Name, Skill, Job_Application_ID),
    FOREIGN KEY (Job_Application_ID) REFERENCES open_positions(Job_Application_ID) ON DELETE CASCADE
);


DELIMITER $$

CREATE PROCEDURE InsertIntoOpenPositionsSkills()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_Project_Name VARCHAR(20);
    DECLARE v_Open_Positions VARCHAR(50);
    DECLARE v_Key_Skills VARCHAR(50);
    DECLARE v_Job_Application_ID VARCHAR(20);
    DECLARE skill VARCHAR(50);

    -- Cursor to loop through open_positions table
    DECLARE skill_cursor CURSOR FOR 
        SELECT Project_Name, Open_Positions, Key_Skills, Job_Application_ID 
        FROM open_positions;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN skill_cursor;

    read_loop: LOOP
        FETCH skill_cursor INTO v_Project_Name, v_Open_Positions, v_Key_Skills, v_Job_Application_ID;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Loop through each skill in the comma-separated list
        WHILE LENGTH(v_Key_Skills) > 0 DO
            SET skill = SUBSTRING_INDEX(v_Key_Skills, ',', 1);  -- Extract first skill
            SET v_Key_Skills = IF(LOCATE(',', v_Key_Skills) > 0, SUBSTRING(v_Key_Skills, LOCATE(',', v_Key_Skills) + 1), '');  -- Remove the extracted skill

            -- Insert each skill separately
            INSERT INTO open_positions_skills (Project_Name, Open_Positions, Skill, Job_Application_ID)
            VALUES (v_Project_Name, v_Open_Positions, skill, v_Job_Application_ID);
        END WHILE;
    END LOOP;

    CLOSE skill_cursor;
END$$

DELIMITER ;


CALL InsertIntoOpenPositionsSkills();

SELECT * FROM open_positions_skills;



DELIMITER $$

CREATE TRIGGER trg_InsertOpenPositionsSkills
AFTER INSERT ON open_positions
FOR EACH ROW
BEGIN
    DECLARE skill VARCHAR(50);
    DECLARE remaining_skills VARCHAR(50);

    SET remaining_skills = NEW.Key_Skills;  -- Get the skills from the inserted row

    -- Loop through each skill in the comma-separated list
    WHILE LENGTH(remaining_skills) > 0 DO
        SET skill = SUBSTRING_INDEX(remaining_skills, ',', 1);  -- Extract first skill
        SET remaining_skills = IF(LOCATE(',', remaining_skills) > 0, 
                                  SUBSTRING(remaining_skills, LOCATE(',', remaining_skills) + 1), 
                                  '');  -- Remove the extracted skill

        -- Insert each skill separately into open_positions_skills
        INSERT INTO open_positions_skills (Project_Name, Open_Positions, Skill, Job_Application_ID)
        VALUES (NEW.Project_Name, NEW.Open_Positions, skill, NEW.Job_Application_ID);
    END WHILE;
END$$

DELIMITER ;




INSERT INTO open_positions (Project_Name, Open_Positions, Key_Skills, Job_Application_ID)
VALUES ('Project A', 'Data Scientist', 'Python,SQL,Machine Learning', 'D1001');

select * from open_positions_skills
where Job_Application_ID='d1001';

delete from open_positions
where Job_Application_ID='d1001';