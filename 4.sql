use sql_project;

SELECT distinct
	j.Applicant_Name,  
    j.Experience_of_Applicant, 
    -- j.Skill, 
    j.Job_Application_ID, 
    o.Project_Name, 
	o.Open_Positions
FROM job_applications_skills j  
JOIN open_positions_skills o  
ON j.Skill = o.Skill
AND j.Job_Application_ID=o.Job_Application_ID;



create table filter_candidate(
Applicant_Name varchar(50) primary key,
Experience_of_Applicant int,
Job_Application_ID varchar(20),
Project_Name varchar(30),
Open_Positions varchar(50));


select*from filter_candidate



insert into filter_candidate
select * from(SELECT distinct
	j.Applicant_Name,  
    j.Experience_of_Applicant, 
    -- j.Skill, 
    j.Job_Application_ID, 
    o.Project_Name, 
	o.Open_Positions
FROM job_applications_skills j  
JOIN open_positions_skills o  
ON j.Skill = o.Skill
AND j.Job_Application_ID=o.Job_Application_ID) k;



DELIMITER //

CREATE PROCEDURE InsertIntoFilterCandidate()
BEGIN
    INSERT INTO filter_candidate (Applicant_Name, Experience_of_Applicant, Job_Application_ID, Project_Name, Open_Positions)
    SELECT DISTINCT
        j.Applicant_Name,  
        j.Experience_of_Applicant,  
        j.Job_Application_ID, 
        o.Project_Name, 
        o.Open_Positions
    FROM job_applications_skills j  
    JOIN open_positions_skills o  
    ON j.Skill = o.Skill
    AND j.Job_Application_ID = o.Job_Application_ID;
END //

DELIMITER ;




DELIMITER //

CREATE TRIGGER after_insert_job_applications_skills
AFTER INSERT ON job_applications_skills
FOR EACH ROW
BEGIN
    CALL InsertIntoFilterCandidate();
END //

CREATE TRIGGER after_insert_open_positions_skills
AFTER INSERT ON open_positions_skills
FOR EACH ROW
BEGIN
    CALL InsertIntoFilterCandidate();
END //

DELIMITER ;


CREATE TABLE IF NOT EXISTS final_candidate (
    Applicant_Name VARCHAR(50),
    Job_Application_ID VARCHAR(20),
    Status ENUM('Selected'),
    PRIMARY KEY (Applicant_Name, Job_Application_ID)
);

CREATE TABLE IF NOT EXISTS interview_process (
    Applicant_Name VARCHAR(50),
    Job_Application_ID VARCHAR(20),
    Round INT,
    Status ENUM('Yes', 'No'),
    PRIMARY KEY (Applicant_Name, Job_Application_ID, Round)
);







DELIMITER //

CREATE PROCEDURE SmartUpdateInterviewProcessStatus(
    IN p_Applicant_Name VARCHAR(50),
    IN p_Job_Application_ID VARCHAR(20),
    IN p_Round INT,
    IN p_Status ENUM('Yes', 'No')
)
BEGIN
    DECLARE round1_status ENUM('Yes', 'No');
    DECLARE round2_status ENUM('Yes', 'No');

    -- Insert or update status for the round
    INSERT INTO interview_process(Applicant_Name, Job_Application_ID, Round, Status)
    VALUES (p_Applicant_Name, p_Job_Application_ID, p_Round, p_Status)
    ON DUPLICATE KEY UPDATE Status = p_Status;

    -- Check if candidate qualifies for final_candidate
    IF p_Round = 3 THEN
        -- Get previous round statuses
        SELECT Status INTO round1_status
        FROM interview_process
        WHERE Applicant_Name = p_Applicant_Name AND Job_Application_ID = p_Job_Application_ID AND Round = 1;

        SELECT Status INTO round2_status
        FROM interview_process
        WHERE Applicant_Name = p_Applicant_Name AND Job_Application_ID = p_Job_Application_ID AND Round = 2;

        -- Insert into final_candidate if all rounds passed
        IF round1_status = 'Yes' AND round2_status = 'Yes' AND p_Status = 'Yes' THEN
            INSERT INTO final_candidate(Applicant_Name, Job_Application_ID, Status)
            VALUES (p_Applicant_Name, p_Job_Application_ID, 'Selected')
            ON DUPLICATE KEY UPDATE Status = 'Selected';
        END IF;
    END IF;
END //

DELIMITER ;


select * from filter_candidate;
-- Round 1 passed
CALL SmartUpdateInterviewProcessStatus('Aurora Ali', 'J1004', 1, 'yes');

-- Round 2 passed
CALL SmartUpdateInterviewProcessStatus('Aurora Ali', 'J1004', 2, 'Yes');

-- Round 3 passed → gets added to final_candidate
CALL SmartUpdateInterviewProcessStatus('Aurora Ali', 'J1004', 3, 'Yes');



select *from interview_process
select * from filter_candidate;

CREATE TABLE IF NOT EXISTS final_candidate (
    Applicant_Name VARCHAR(50),
    Job_Application_ID VARCHAR(20),
    Status ENUM('Selected'),
    PRIMARY KEY (Applicant_Name, Job_Application_ID)
);




DELIMITER //

CREATE PROCEDURE SmartUpdateInterviewProcessStatus(
    IN p_Applicant_Name VARCHAR(50),
    IN p_Job_Application_ID VARCHAR(20),
    IN p_Round INT,
    IN p_Status ENUM('Yes', 'No')
)
BEGIN
    DECLARE round1_status ENUM('Yes', 'No');
    DECLARE round2_status ENUM('Yes', 'No');

    -- Insert or update status for the round
    INSERT INTO interview_process(Applicant_Name, Job_Application_ID, Round, Status)
    VALUES (p_Applicant_Name, p_Job_Application_ID, p_Round, p_Status)
    ON DUPLICATE KEY UPDATE Status = p_Status;

    -- Check if candidate qualifies for final_candidate
    IF p_Round = 3 THEN
        -- Get previous round statuses
        SELECT Status INTO round1_status
        FROM interview_process
        WHERE Applicant_Name = p_Applicant_Name AND Job_Application_ID = p_Job_Application_ID AND Round = 1;

        SELECT Status INTO round2_status
        FROM interview_process
        WHERE Applicant_Name = p_Applicant_Name AND Job_Application_ID = p_Job_Application_ID AND Round = 2;

        -- Insert into final_candidate if all rounds passed
        IF round1_status = 'Yes' AND round2_status = 'Yes' AND p_Status = 'Yes' THEN
            INSERT INTO final_candidate(Applicant_Name, Job_Application_ID, Status)
            VALUES (p_Applicant_Name, p_Job_Application_ID, 'Selected')
            ON DUPLICATE KEY UPDATE Status = 'Selected';
        END IF;
    END IF;
END //

DELIMITER ;



select	* from final_candidate