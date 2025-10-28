# 🧰 Relational-DB-Design-Car-Care-Hub
An advanced PostgreSQL database schema for a car service business — featuring enforced business logic, 3NF normalization, and performance-driven indexing.

# 🚗 Relational Database Design: Car Service Hub

This repository contains the complete PostgreSQL schema for a full-featured **Car Service Hub** system.  
It’s not just a set of tables, but a well-structured, normalized, and optimized relational database built to model a real-world car service enterprise.

The project serves as a **capstone demonstration** of database architecture, normalization, and embedded business logic at the SQL level.

---

## 🏗️ Project Overview

The database models the full workflow of a multi-location car service business.  
It captures complex relationships between **customers, vehicles, bookings, inventory, staff,** and **invoicing** while enforcing data integrity and scalability.

---

## ⚙️ Key Features & Demonstrated Skills

This project showcases advanced PostgreSQL design, emphasizing data consistency, normalization, and performance optimization.

---

### 1. 🧩 Database Architecture (3NF)

The schema follows **Third Normal Form (3NF)**, minimizing redundancy and ensuring data consistency.  

**Core design modules include:**
- **Staff & Qualifications:** `staff`, `qualification`, and `staff_qualification` junction table.  
- **Services & Departments:** `department` and `dept_type` lookup table.  
- **Parts & Inventory:** `part`, `part_category`, and `manufacturer`.

---

### 2. 🧱 Advanced Data Integrity

Integrity is strictly enforced at the database level using multiple constraint layers:
- **Primary & Foreign Keys** ensure relational consistency.  
- **`UNIQUE` constraints** maintain data uniqueness (`role_name`, `part_oem_number`).  
- **`CHECK` constraints** validate business rules (`part_quantity >= 0`, `service_cost > 0`).  
- **Custom ENUM Types** (`booking_status`) guarantee valid, standardized input values.

---

### 3. 🚀 Performance Optimization

Indexes are strategically designed for optimal performance:
- **`CREATE INDEX`** used on foreign key columns and frequently filtered attributes such as `cust_last_name`, `car_reg`, and `booking_status`.  
- This structure ensures efficient query execution for both analytical and transactional workloads.

---

### 4. 🧠 Embedded Business Logic (Triggers)

Business intelligence is integrated directly within the database layer using **PL/pgSQL trigger functions**.

#### 🔄 `check_appointment_overlap()`
A pre-insert and pre-update trigger on `service_detail`:
- Automatically detects overlapping bookings for the same staff member.
- Prevents double scheduling by rejecting invalid inserts at the source.  
- Guarantees **data integrity and operational accuracy** without relying on application logic.

---

## 🗂️ Schema Modules Overview

| Module | Description |
|--------|--------------|
| **Customers & Cars** | Manages customers and their registered vehicles. |
| **Staff & Departments** | Handles employees, their qualifications, and departmental structure. |
| **Services & Inventory** | Defines offered services, tracks available parts and suppliers. |
| **Bookings & Invoicing** | Core operational layer linking cars, services, staff, and payments. |
| **Feedback** | Captures customer reviews and satisfaction data for business insight. |

---

## 👩‍💻 Author
**Denisa R.**  
*Computer Science Student – University of Portsmouth*
