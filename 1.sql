create database sql_project;
use sql_project;


CREATE TABLE existing_employees (
    Employee_ID VARCHAR(25) PRIMARY KEY,
    Employee_Name varchar(50),
    Salary BIGINT,
    Project_ID VARCHAR(25),
    Project_Name varchar(50),
    Client_ID VARCHAR(25),
    Client_Name varchar(50),
    Project_Budget BIGINT,
    Employee_Hire_Date DATE,
    Project_Duration_in_Days BIGINT,
    Employee_Designation varchar(50),
    Employee_Skills varchar(50),
    Emp_Phone_No BIGINT,
    Office_Location varchar(50),
    We_Region varchar(50),
    Employee_Gender varchar(20)
);



CREATE TABLE existing_employees_permanent (
    Employee_ID VARCHAR(25) PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Salary BIGINT,
    Project_ID VARCHAR(25),
    Project_Name VARCHAR(50),
    Client_ID VARCHAR(25),
    Client_Name VARCHAR(50),
    Project_Budget BIGINT,
    Employee_Hire_Date DATE,
    Project_Duration_in_Days BIGINT,
    Employee_Designation VARCHAR(50),
    Employee_Skills VARCHAR(50),
    Emp_Phone_No BIGINT,
    Office_Location VARCHAR(50),
    We_Region VARCHAR(50),
    Employee_Gender VARCHAR(20),
    indicator ENUM('yes', 'no') DEFAULT 'yes'
);


INSERT INTO existing_employees_permanent 
SELECT *, 'yes' AS indicator FROM existing_employees;


CREATE TABLE log_table (
    Employee_ID VARCHAR(25),
    Data_inserted ENUM('yes', 'no') DEFAULT 'no',
    Data_updated ENUM('yes', 'no') DEFAULT 'no',
    Data_deleted ENUM('yes', 'no') DEFAULT 'no',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


select * from existing_employees_permanent;
select * from log_table;


DELIMITER $$

DROP PROCEDURE IF EXISTS ManageEmployeeData$$

CREATE PROCEDURE ManageEmployeeData(
    IN p_Employee_ID VARCHAR(50),
    IN p_Employee_Name VARCHAR(100),
    IN p_Salary DECIMAL(10,2),
    IN p_Project_ID VARCHAR(50),
    IN p_Project_Name VARCHAR(100),
    IN p_Client_ID VARCHAR(50),
    IN p_Client_Name VARCHAR(100),
    IN p_Project_Budget DECIMAL(15,2),
    IN p_Employee_Hire_Date DATE,
    IN p_Project_Duration_in_Days INT,
    IN p_Employee_Designation VARCHAR(100),
    IN p_Employee_Skills TEXT,
    IN p_Emp_Phone_No VARCHAR(20),
    IN p_Office_Location VARCHAR(100),
    IN p_We_Region VARCHAR(50),
    IN p_Employee_Gender VARCHAR(10),
    IN p_Action VARCHAR(10) -- 'insert', 'update', or 'delete'
)
BEGIN
    IF p_Action = 'insert' THEN
        -- Insert into existing_employees_permanent
        INSERT INTO existing_employees_permanent (
            Employee_ID, Employee_Name, Salary, Project_ID, Project_Name, Client_ID, Client_Name, Project_Budget,
            Employee_Hire_Date, Project_Duration_in_Days, Employee_Designation, Employee_Skills, Emp_Phone_No,
            Office_Location, We_Region, Employee_Gender, indicator
        )
        VALUES (
            p_Employee_ID, p_Employee_Name, p_Salary, p_Project_ID, p_Project_Name, p_Client_ID, p_Client_Name, p_Project_Budget,
            p_Employee_Hire_Date, p_Project_Duration_in_Days, p_Employee_Designation, p_Employee_Skills, p_Emp_Phone_No,
            p_Office_Location, p_We_Region, p_Employee_Gender, 'yes'
        )
        ON DUPLICATE KEY UPDATE 
            Employee_Name = p_Employee_Name,
            Salary = p_Salary,
            Project_ID = p_Project_ID,
            Project_Name = p_Project_Name,
            Client_ID = p_Client_ID,
            Client_Name = p_Client_Name,
            Project_Budget = p_Project_Budget,
            Employee_Hire_Date = p_Employee_Hire_Date,
            Project_Duration_in_Days = p_Project_Duration_in_Days,
            Employee_Designation = p_Employee_Designation,
            Employee_Skills = p_Employee_Skills,
            Emp_Phone_No = p_Emp_Phone_No,
            Office_Location = p_Office_Location,
            We_Region = p_We_Region,
            Employee_Gender = p_Employee_Gender,
            indicator = 'yes';

        -- Insert log entry
        INSERT INTO log_table (Employee_ID, Data_inserted, Data_updated, Data_deleted)
        VALUES (p_Employee_ID, 'yes', 'no', 'no')
        ON DUPLICATE KEY UPDATE Data_inserted = 'yes', Data_updated = 'no', Data_deleted = 'no';

    ELSEIF p_Action = 'update' THEN
        -- Update existing_employees_permanent
        UPDATE existing_employees_permanent
        SET 
            Employee_Name = p_Employee_Name,
            Salary = p_Salary,
            Project_ID = p_Project_ID,
            Project_Name = p_Project_Name,
            Client_ID = p_Client_ID,
            Client_Name = p_Client_Name,
            Project_Budget = p_Project_Budget,
            Employee_Hire_Date = p_Employee_Hire_Date,
            Project_Duration_in_Days = p_Project_Duration_in_Days,
            Employee_Designation = p_Employee_Designation,
            Employee_Skills = p_Employee_Skills,
            Emp_Phone_No = p_Emp_Phone_No,
            Office_Location = p_Office_Location,
            We_Region = p_We_Region,
            Employee_Gender = p_Employee_Gender,
            indicator = 'yes'
        WHERE Employee_ID = p_Employee_ID;

        -- Update log_table
        INSERT INTO log_table (Employee_ID, Data_inserted, Data_updated, Data_deleted)
        VALUES (p_Employee_ID, 'no', 'yes', 'no')
        ON DUPLICATE KEY UPDATE Data_inserted = 'no', Data_updated = 'yes', Data_deleted = 'no';

    ELSEIF p_Action = 'delete' THEN
        -- Mark employee as deleted in existing_employees_permanent
        UPDATE existing_employees_permanent
        SET indicator = 'no'
        WHERE Employee_ID = p_Employee_ID;

        -- Update log_table
        INSERT INTO log_table (Employee_ID, Data_inserted, Data_updated, Data_deleted)
        VALUES (p_Employee_ID, 'no', 'no', 'yes')
        ON DUPLICATE KEY UPDATE Data_inserted = 'no', Data_updated = 'no', Data_deleted = 'yes';

    END IF;
END$$

DELIMITER 




-- Create TRIGER FOR CALLING STORE PROCIDURE for automatically insert

DELIMITER $$

CREATE TRIGGER after_insert_existing_employees
AFTER INSERT ON existing_employees
FOR EACH ROW
BEGIN
    CALL ManageEmployeeData(
        NEW.Employee_ID, NEW.Employee_Name, NEW.Salary, NEW.Project_ID, NEW.Project_Name, NEW.Client_ID, 
        NEW.Client_Name, NEW.Project_Budget, NEW.Employee_Hire_Date, NEW.Project_Duration_in_Days, 
        NEW.Employee_Designation, NEW.Employee_Skills, NEW.Emp_Phone_No, NEW.Office_Location, NEW.We_Region, 
        NEW.Employee_Gender, 'insert'
    );
END$$

DELIMITER ;

-- Create TRIGER FOR CALLING STORE PROCIDURE for automatically UPDATE

DELIMITER $$

CREATE TRIGGER after_update_existing_employees
AFTER UPDATE ON existing_employees
FOR EACH ROW
BEGIN
    CALL ManageEmployeeData(
        NEW.Employee_ID, NEW.Employee_Name, NEW.Salary, NEW.Project_ID, NEW.Project_Name, NEW.Client_ID, 
        NEW.Client_Name, NEW.Project_Budget, NEW.Employee_Hire_Date, NEW.Project_Duration_in_Days, 
        NEW.Employee_Designation, NEW.Employee_Skills, NEW.Emp_Phone_No, NEW.Office_Location, NEW.We_Region, 
        NEW.Employee_Gender, 'update'
    );
END$$

DELIMITER ;

-- Create TRIGER FOR CALLING STORE PROCIDURE for automatically DELETE

DELIMITER $$

CREATE TRIGGER after_delete_existing_employees
AFTER DELETE ON existing_employees
FOR EACH ROW
BEGIN
    CALL ManageEmployeeData(
        OLD.Employee_ID, OLD.Employee_Name, OLD.Salary, OLD.Project_ID, OLD.Project_Name, OLD.Client_ID, 
        OLD.Client_Name, OLD.Project_Budget, OLD.Employee_Hire_Date, OLD.Project_Duration_in_Days, 
        OLD.Employee_Designation, OLD.Employee_Skills, OLD.Emp_Phone_No, OLD.Office_Location, OLD.We_Region, 
        OLD.Employee_Gender, 'delete'
    );
END$$

DELIMITER ;

select * from existing_employees;
select * from existing_employees_permanent;
select * from log_table;