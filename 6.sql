use sql_project;

CREATE TABLE IF NOT EXISTS project_budget_tracker (
    project_id VARCHAR(25) PRIMARY KEY,
    remaining_budget BIGINT
);



INSERT INTO project_budget_tracker (project_id, remaining_budget)
SELECT 
    p.Project_ID,
    (p.Project_Budget - IFNULL(SUM(e.Salary), 0)) AS remaining_budget
FROM projects p
LEFT JOIN employee_projects ep ON p.Project_ID = ep.Project_ID
LEFT JOIN employees e ON ep.Employee_ID = e.Employee_ID
GROUP BY p.Project_ID;



CREATE TABLE IF NOT EXISTS new_employee_salary (
    employee_id VARCHAR(20) PRIMARY KEY,
    employee_name VARCHAR(50),
    project_id VARCHAR(25),
    project_name VARCHAR(50),
    salary BIGINT,
    remaining_budget BIGINT
);


DELIMITER //

CREATE PROCEDURE insert_new_employee_salary_sequential(
    IN p_job_app_id VARCHAR(20), 
    IN p_applicant_name VARCHAR(50)
)
BEGIN
    DECLARE v_project_id VARCHAR(25);
    DECLARE v_project_name VARCHAR(50);
    DECLARE v_remaining_budget BIGINT;
    DECLARE v_salary BIGINT;
    DECLARE v_final_budget BIGINT;

    -- 1. Get project with highest remaining budget
    SELECT 
        pbt.project_id,
        p.Project_Name,
        pbt.remaining_budget
    INTO 
        v_project_id,
        v_project_name,
        v_remaining_budget
    FROM project_budget_tracker pbt
    JOIN projects p ON pbt.project_id = p.Project_ID
    ORDER BY pbt.remaining_budget DESC
    LIMIT 1;

    -- 2. Calculate salary = 30% of remaining budget
    SET v_salary = ROUND(v_remaining_budget * 0.3);

    -- 3. Update remaining budget
    SET v_final_budget = v_remaining_budget - v_salary;

    -- 4. Insert into new_employee_salary
    INSERT INTO new_employee_salary(employee_id, employee_name, project_id, project_name, salary, remaining_budget)
    VALUES (p_job_app_id, p_applicant_name, v_project_id, v_project_name, v_salary, v_final_budget);

    -- 5. Update budget tracker
    UPDATE project_budget_tracker
    SET remaining_budget = v_final_budget
    WHERE project_id = v_project_id;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_after_selected_candidate_insert
AFTER INSERT ON final_candidate
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Selected' THEN
        CALL insert_new_employee_salary_sequential(NEW.Job_Application_ID, NEW.Applicant_Name);
    END IF;
END //

DELIMITER ;



DELIMITER //

CREATE TRIGGER trg_after_selected_candidate_update
AFTER UPDATE ON final_candidate
FOR EACH ROW
BEGIN
    -- If changed to "Selected", insert
    IF NEW.Status = 'Selected' AND OLD.Status != 'Selected' THEN
        CALL insert_new_employee_salary_sequential(NEW.Job_Application_ID, NEW.Applicant_Name);
    END IF;

    -- If changed from "Selected" to something else, delete
    IF NEW.Status != 'Selected' AND OLD.Status = 'Selected' THEN
        DELETE FROM new_employee_salary
        WHERE employee_id = OLD.Job_Application_ID;
    END IF;
END //

DELIMITER ;


select * from new_employee_salary;
select * from project_budget_tracker;
select * from existing_employees;