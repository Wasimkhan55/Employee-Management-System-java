-- ==========================================
-- 1. Create Database
-- ==========================================
CREATE DATABASE IF NOT EXISTS management;
USE management;

-- ==========================================
-- 2. Drop old tables if they exist (correct order)
-- ==========================================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS performance_reviews;
DROP TABLE IF EXISTS leave_applications;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS employees;

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- 3. Create tables
-- ==========================================

-- 3.1 Employees master table
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    emp_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    designation VARCHAR(100),
    salary DECIMAL(10,2),
    doj DATE,
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255),
    status ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

-- 3.2 Users table (for Admin + Employee login)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role ENUM('ADMIN','EMPLOYEE') NOT NULL,
    employee_id INT NULL,
    CONSTRAINT fk_users_employee
        FOREIGN KEY (employee_id) REFERENCES employees(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.3 Attendance table
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('PRESENT','ABSENT','LEAVE') NOT NULL,
    check_in TIME NULL,
    check_out TIME NULL,
    CONSTRAINT fk_attendance_employee
        FOREIGN KEY (employee_id) REFERENCES employees(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_attendance UNIQUE (employee_id, date)
) ENGINE=InnoDB;

-- 3.4 Leave applications table
CREATE TABLE leave_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    type VARCHAR(50) NOT NULL,
    reason VARCHAR(255),
    status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_by INT NULL,
    action_at TIMESTAMP NULL,
    CONSTRAINT fk_leave_employee
        FOREIGN KEY (employee_id) REFERENCES employees(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_leave_action_by
        FOREIGN KEY (action_by) REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.5 Performance reviews table
CREATE TABLE performance_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    review_date DATE NOT NULL,
    rating INT NOT NULL,
    remarks VARCHAR(255),
    reviewer VARCHAR(100),
    CONSTRAINT fk_performance_employee
        FOREIGN KEY (employee_id) REFERENCES employees(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 10)
) ENGINE=InnoDB;

-- ==========================================
-- 4. Sample data for testing
-- ==========================================

-- 4.1 Sample employee
INSERT INTO employees (
    emp_code, name, department, designation, salary, doj,
    phone, email, address, status
) VALUES (
    'EMP001', 'Demo Employee', 'IT', 'Developer',
    35000.00, '2023-01-01',
    '9999999999', 'demo@company.com', 'Demo Address', 'ACTIVE'
);

-- 4.2 Admin user (no employee_id)
INSERT INTO users (username, password, role, employee_id)
VALUES ('admin', 'admin123', 'ADMIN', NULL);

-- 4.3 Employee login mapped to EMP001
INSERT INTO users (username, password, role, employee_id)
SELECT 'emp1', 'emp123', 'EMPLOYEE', e.id
FROM employees e
WHERE e.emp_code = 'EMP001'
LIMIT 1;
