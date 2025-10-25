-- dropping tables
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS service_detail;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS staff_qualification;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS service;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS part;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS pay_method;
DROP TABLE IF EXISTS part_category;
DROP TABLE IF EXISTS manufacturer;
DROP TABLE IF EXISTS dept_type;
DROP TABLE IF EXISTS qualification;
DROP TABLE IF EXISTS role;

-- creating custom data type
DROP TYPE IF EXISTS booking_status;
CREATE TYPE booking_status AS ENUM ('Complete', 'Cancelled', 'Scheduled', 'In Progress');

-- creating the tables
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(75) NOT NULL UNIQUE
);

CREATE TABLE qualification (
    qual_id SERIAL PRIMARY KEY,
    qual_name VARCHAR(75) NOT NULL UNIQUE
);

CREATE TABLE dept_type (
    dept_type_id SMALLSERIAL PRIMARY KEY,
    dept_type_name VARCHAR(75) NOT NULL UNIQUE
);

CREATE TABLE manufacturer (
    manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(75) NOT NULL UNIQUE,
    manufacturer_phone VARCHAR(15) NOT NULL UNIQUE
);

CREATE INDEX idx_manufacturer_name ON manufacturer (manufacturer_name);

CREATE TABLE part_category (
    part_cat_id SERIAL PRIMARY KEY,
    part_cat_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE pay_method (
    pay_method_id SERIAL PRIMARY KEY,
    pay_method_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE customer (
    cust_id SERIAL PRIMARY KEY,
    cust_first_name VARCHAR(50) NOT NULL,
    cust_mid_name VARCHAR(50),
    cust_last_name VARCHAR(50) NOT NULL,
    cust_addr1 VARCHAR(30) NOT NULL,
    cust_addr2 VARCHAR(30),
    cust_city VARCHAR(30) NOT NULL,
    cust_postcode VARCHAR(8) NOT NULL,
    cust_phone VARCHAR(15) NOT NULL,
    cust_email VARCHAR(150) NOT NULL
);

CREATE INDEX idx_cust_last_name ON customer (cust_last_name);
CREATE INDEX idx_cust_city ON customer (cust_city);

CREATE TABLE part (
    part_id SERIAL PRIMARY KEY,
    manufacturer_id INT NOT NULL REFERENCES manufacturer(manufacturer_id),
    part_cat_id INT NOT NULL REFERENCES part_category(part_cat_id),
    part_name VARCHAR(75) NOT NULL,
    part_oem_number VARCHAR(50) NOT NULL UNIQUE,
    part_quantity INT NOT NULL CHECK (part_quantity >= 0)
);

CREATE INDEX idx_part_name ON part (part_name);
CREATE INDEX idx_part_oem_number ON part (part_oem_number);

CREATE TABLE department (
    dept_id SMALLSERIAL PRIMARY KEY,
    dept_type_id INT NOT NULL REFERENCES dept_type(dept_type_id),
    dept_name VARCHAR(75) NOT NULL UNIQUE,
    dept_phone VARCHAR(15) NOT NULL UNIQUE,
    dept_email VARCHAR(150) NOT NULL UNIQUE
);

CREATE INDEX idx_dept_name ON department (dept_name);

CREATE TABLE service (
    service_id SERIAL PRIMARY KEY,
    dept_id INT NOT NULL REFERENCES department(dept_id),
    service_name VARCHAR(75) NOT NULL UNIQUE,
    service_description VARCHAR(200) NOT NULL,
    service_duration DECIMAL(4, 1) NOT NULL CHECK (MOD(service_duration, 0.5) = 0),
    service_cost DECIMAL(7, 2) NOT NULL CHECK (service_cost > 0)
);

CREATE INDEX idx_service_name ON service (service_name);

CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    dept_id INT NOT NULL REFERENCES department(dept_id),
    location_addr1 VARCHAR(30) NOT NULL,
    location_addr2 VARCHAR(30),
    location_city VARCHAR(30) NOT NULL,
    location_postcode VARCHAR(8) NOT NULL,
    UNIQUE (location_addr1, location_addr2, location_city, location_postcode)
);

CREATE INDEX idx_location_city ON location (location_city);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    dept_id INT NOT NULL REFERENCES department(dept_id),
    role_id INT NOT NULL REFERENCES role(role_id),
    staff_first_name VARCHAR(50) NOT NULL,
    staff_mid_name VARCHAR(50),
    staff_last_name VARCHAR(50) NOT NULL,
    staff_addr1 VARCHAR(30) NOT NULL,
    staff_addr2 VARCHAR(30),
    staff_city VARCHAR(30) NOT NULL,
    staff_postcode VARCHAR(8) NOT NULL,
    staff_phone VARCHAR(15) NOT NULL UNIQUE,
    staff_personal_email VARCHAR(150) UNIQUE,
    staff_business_email VARCHAR(150) NOT NULL UNIQUE,
    staff_date_joined DATE NOT NULL
);

CREATE INDEX idx_staff_last_name ON staff (staff_last_name);
CREATE INDEX idx_staff_city ON staff (staff_city);
CREATE INDEX idx_staff_business_email ON staff (staff_business_email);

CREATE TABLE staff_qualification (
    qual_id INT NOT NULL REFERENCES qualification(qual_id),
    staff_id INT NOT NULL REFERENCES staff(staff_id),
    acquired_date DATE NOT NULL,
    exp_date DATE
);

CREATE INDEX idx_exp_date ON staff_qualification (exp_date);

CREATE TABLE car (
    car_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL REFERENCES customer(cust_id),
    car_reg VARCHAR(8) NOT NULL UNIQUE,
    car_make VARCHAR(50) NOT NULL,
    car_model VARCHAR(50) NOT NULL,
    car_colour VARCHAR(20),
    car_last_mot DATE
);

CREATE INDEX idx_car_model ON car (car_model);

CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    car_id INT NOT NULL REFERENCES car(car_id),
    location_id INT NOT NULL REFERENCES location(location_id),
    booking_status booking_status NOT NULL, -- uses custom enum type
    booking_comments VARCHAR(200),
    booking_booked DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE INDEX idx_booking_status ON booking (booking_status);
CREATE INDEX idx_booking_booked ON booking (booking_booked);

CREATE TABLE service_detail (
    serv_det_id INT NOT NULL,
    booking_id INT NOT NULL REFERENCES booking(booking_id),
    service_id INT NOT NULL REFERENCES service(service_id),
    staff_id INT NOT NULL REFERENCES staff(staff_id),
    part_id INT REFERENCES part(part_id),
    serv_det_part_qty SMALLINT,
    serv_det_date DATE NOT NULL DEFAULT CURRENT_DATE,
    serv_det_start TIME NOT NULL,
    serv_det_end TIME NOT NULL DEFAULT LOCALTIME(0),
    serv_det_add_cost DECIMAL(7, 2),
    serv_det_report_date DATE NOT NULL,
    serv_det_notes VARCHAR(200) NOT NULL,
    PRIMARY KEY (serv_det_id, booking_id, service_id, staff_id)
);

CREATE INDEX idx_serv_det_date ON service_detail (serv_det_date);

CREATE TABLE invoice (
    inv_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES booking(booking_id),
    inv_description VARCHAR(200) NOT NULL,
    inv_created_at DATE NOT NULL DEFAULT CURRENT_DATE,
    inv_total DECIMAL(7, 2) NOT NULL,
    inv_payment_due DATE NOT NULL,
    inv_instalments INT NOT NULL CHECK (inv_instalments > 0)
);

CREATE INDEX idx_inv_total ON invoice (inv_total);
CREATE INDEX idx_inv_payment_due ON invoice (inv_payment_due);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    inv_id INT NOT NULL REFERENCES invoice(inv_id),
    pay_method_id INT NOT NULL REFERENCES pay_method(pay_method_id),
    payment_instal_no INT NOT NULL CHECK (payment_instal_no > 0),
    payment_amount DECIMAL(7, 2) NOT NULL CHECK (payment_amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_time TIME NOT NULL DEFAULT LOCALTIME(0),
    CHECK (payment_date < CURRENT_DATE OR (payment_date = CURRENT_DATE AND payment_time <= LOCALTIME(0)))
);

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL REFERENCES customer(cust_id),
    feedback_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    feedback_text VARCHAR(300) NOT NULL
);

-- function for trigger
CREATE OR REPLACE FUNCTION check_appointment_overlap()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
    AS
    $$
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM service_detail sd
            WHERE NEW.staff_id = sd.staff_id
                AND NEW.serv_det_date = sd.serv_det_date
                AND (NEW.serv_det_start, NEW.serv_det_end) OVERLAPS (sd.serv_det_start, sd.serv_det_end)
        )
        THEN RAISE EXCEPTION 'This staff member already has an appointment at this time.';
        END IF;
        RETURN NEW;
    END;
    $$;

-- creating trigger
DROP TRIGGER IF EXISTS appointment_overlap_trigger ON service_detail;
CREATE TRIGGER appointment_overlap_trigger
    BEFORE INSERT OR UPDATE
    ON service_detail
    FOR EACH ROW
    EXECUTE PROCEDURE check_appointment_overlap();
