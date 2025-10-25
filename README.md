# Relational-DB-Design-Car-Care-Hub
An advanced PostgreSQL schema for a car service business, featuring business logic triggers, 3NF normalization, and performance indexes.

# Relational Database Design: Car Service Hub

This repository contains the complete database schema for a comprehensive "Car Service Hub" application. This project is not just a collection of tables, but a fully designed, normalized, and optimized relational database built in PostgreSQL.

It serves as a capstone project demonstrating database architecture, data integrity, and the implementation of advanced business logic at the database level.

## Project Overview

The database is designed to manage all operations of a multi-location car repair and service business. It models the complex relationships between customers, their vehicles, service bookings, parts inventory, staff assignments, and invoicing.

## Key Features & Demonstrated Skills

This schema demonstrates a deep understanding of database design principles and advanced PostgreSQL features.

### 1. Database Architecture (3NF)
The schema is designed in Third Normal Form (3NF) to reduce data redundancy and improve data integrity. This is visible in the normalization of entities:
* **Staff & Qualifications:** `staff`, `qualification`, and the `staff_qualification` junction table.
* **Services & Departments:** `department` and `dept_type` lookup table.
* **Parts & Inventory:** `part`, `part_category`, and `manufacturer`.

### 2. Advanced Data Integrity
Data integrity is enforced at the database level through a rigorous set of constraints:
* **Primary and Foreign Keys** to maintain relational integrity.
* **`UNIQUE` constraints** on business keys (e.g., `role_name`, `part_oem_number`).
* **`CHECK` constraints** to enforce business rules (e.g., `part_quantity >= 0`, `service_cost > 0`).
* **Custom Data Types** (`CREATE TYPE ... AS ENUM`) for fields like `booking_status` to ensure valid inputs.

### 3. Performance Optimization
The schema is pre-optimized for common query patterns using:
* **`CREATE INDEX`:** Indexes are strategically placed on foreign keys and columns frequently used in `WHERE` clauses (e.g., `cust_last_name`, `car_reg`, `booking_status`) to accelerate query performance.

### 4. Embedded Business Logic (Triggers)
The most advanced feature is the implementation of business logic directly within the database using a **Trigger Function**:
* **`check_appointment_overlap()`**: This `PL/pgSQL` function runs as a `TRIGGER` before any `INSERT` or `UPDATE` on the `service_detail` table.
* It automatically checks if the assigned staff member is already booked for an overlapping time slot on that day, preventing double-bookings and ensuring data validity at the source.

## Schema Modules

The database is logically divided into several key modules:

* **Customers & Cars:** Manages customer information and their associated vehicles.
* **Staff & Departments:** Manages employees, their roles, qualifications, and the departments they belong to.
* **Services & Inventory:** Defines the services offered by each department and manages the parts inventory from various manufacturers.
* **Booking & Invoicing:** The core operational module, linking `booking`s to `car`s, `location`s, and `service_detail`s. It tracks service execution, staff assignments, parts used, and generates `invoice`s and `payment`s.
* **Feedback:** A simple module for capturing customer feedback.