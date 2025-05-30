use sql_project;


CREATE TABLE offices (
    Office_ID INT AUTO_INCREMENT PRIMARY KEY,
    Office_Location VARCHAR(50),
    We_Region VARCHAR(50)
);


CREATE TABLE employees (
    Employee_ID VARCHAR(25) PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Salary BIGINT,
    Employee_Hire_Date DATE,
    Employee_Designation VARCHAR(50),
    Emp_Phone_No BIGINT,
    Office_ID INT,
    Employee_Gender VARCHAR(20),
    FOREIGN KEY (Office_ID) REFERENCES offices(Office_ID)
);



CREATE TABLE skills (
    Skill_ID INT AUTO_INCREMENT PRIMARY KEY,
    Skill_Name VARCHAR(50) UNIQUE
);


CREATE TABLE clients (
    Client_ID VARCHAR(25) PRIMARY KEY,
    Client_Name VARCHAR(50)
);



CREATE TABLE projects (
    Project_ID VARCHAR(25) PRIMARY KEY,
    Project_Name VARCHAR(50),
    Client_ID VARCHAR(25),
    Project_Budget BIGINT,
    Project_Duration_in_Days BIGINT,
    FOREIGN KEY (Client_ID) REFERENCES clients(Client_ID)
);



CREATE TABLE employee_projects (
    Employee_ID VARCHAR(25),
    Project_ID VARCHAR(25),
    PRIMARY KEY (Employee_ID, Project_ID),
    FOREIGN KEY (Employee_ID) REFERENCES employees(Employee_ID),
    FOREIGN KEY (Project_ID) REFERENCES projects(Project_ID)
);


CREATE TABLE employee_skills (
    Employee_ID VARCHAR(25),
    Skill_ID INT,
    PRIMARY KEY (Employee_ID, Skill_ID),
    FOREIGN KEY (Employee_ID) REFERENCES employees(Employee_ID),
    FOREIGN KEY (Skill_ID) REFERENCES skills(Skill_ID)
);



INSERT INTO offices (Office_Location, We_Region)
SELECT DISTINCT Office_Location, We_Region
FROM existing_employees;


INSERT INTO employees (
    Employee_ID, Employee_Name, Salary, Employee_Hire_Date, 
    Employee_Designation, Emp_Phone_No, Office_ID, Employee_Gender
)
SELECT 
    e.Employee_ID, e.Employee_Name, e.Salary, e.Employee_Hire_Date, 
    e.Employee_Designation, e.Emp_Phone_No, o.Office_ID, e.Employee_Gender
FROM existing_employees e
JOIN offices o 
ON e.Office_Location = o.Office_Location AND e.We_Region = o.We_Region;




INSERT INTO employee_skills (Employee_ID, Skill_ID)
SELECT DISTINCT e.Employee_ID, s.Skill_ID
FROM existing_employees e
JOIN skills s ON FIND_IN_SET(s.Skill_Name, e.Employee_Skills) > 0;


INSERT INTO clients (Client_ID, Client_Name)
SELECT DISTINCT Client_ID, Client_Name
FROM existing_employees;


INSERT INTO projects (Project_ID, Project_Name, Client_ID, Project_Budget, Project_Duration_in_Days)
SELECT DISTINCT Project_ID, Project_Name, Client_ID, Project_Budget, Project_Duration_in_Days
FROM existing_employees;

INSERT INTO employee_projects (Employee_ID, Project_ID)
SELECT DISTINCT Employee_ID, Project_ID
FROM existing_employees;

