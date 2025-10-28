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

-- population inserts
INSERT INTO role (role_name)
VALUES
    ('Head Engine & Transmission'),
    ('Head Electrical Systems'),
    ('Head Bodywork & Painting'),
    ('Head General Maintenance'),
    ('Technician Engine & Transmission'),
    ('Technician Electrical Systems'),
    ('Technician Bodywork & Painting'),
    ('Technician General Maintenance'),
    ('Customer Service Representative'),
    ('Accountant');

INSERT INTO qualification(qual_name)
VALUES
    ('Secondary Education'),
    ('Technical Training'),
    ('Automotive Service Excellence(ASE)');

INSERT INTO dept_type (dept_type_name)
VALUES
    ('Service Department'),
    ('Operational Department');

INSERT INTO manufacturer (manufacturer_name, manufacturer_phone)
VALUES
    ('Seat', '00447563435'),
    ('Mercedes', '00447756435'),
    ('Audi', '00446757899');

INSERT INTO part_category (part_cat_name)
VALUES
    ('Engine Components'),
    ('Electrical Components'),
    ('Body and Exterior');

INSERT INTO pay_method (pay_method_name)
VALUES
    ('card'),
    ('cash');

INSERT INTO customer (cust_first_name, cust_mid_name, cust_last_name, cust_addr1, cust_addr2, cust_city, cust_postcode, cust_phone, cust_email)
VALUES
    ('Carolyn', 'Frédérique', 'Banaszewski', '33 Gina Point', 'Room 1139', 'Kalodu', '6101', '2524793383', 'cbanaszewski0@biglobe.ne.jp'),
    ('Krystalle', 'Sélène', 'Cunnington', '7751 Declaration Crossing', 'Room 1790', 'Ajaccio', '20DEX1', '3854723714', 'kcunnington1@elpais.com'),
    ('Marketa', 'Cloé', 'Hedon', '425 Graceland Place', 'Room 1244', 'Houzhen', '06116', '8708952319', 'mhedon2@ucsd.edu'),
    ('Joeann', 'Sélène', 'Beedom', '757 Lindbergh Crossing', 'Suite 73', 'Jinshi', '356 04', '4814631082', 'jbeedom3@census.gov'),
    ('Gerald', 'Léandre', 'Druitt', '94064 Talisman Drive', 'Apt 665', 'Konsoy', '35664', '8762012353', 'gdruitt4@mozilla.com');

INSERT INTO part (manufacturer_id, part_cat_id, part_name, part_oem_number, part_quantity)
VALUES
    (1, 1, 'Oil', '5789876', 10),
    (1, 1, 'Pump', '3546758', 5),
    (1, 1, 'Filters', '758768', 10),
    (1, 2, 'Relay', '7587565', 1),
    (1, 3, 'Paint', '8758758', 5),
    (2, 3, 'Lacquer', '64765876', 7),
    (2, 3, 'Pedal Box', '87687565', 1),
    (3, 3, 'Transmission Fluid', '873456565', 15),
    (3, 3, 'Battery', '873693365', 1);

INSERT INTO department (dept_type_id, dept_name, dept_phone, dept_email)
VALUES
    (1, 'ENGINE & TRANSMISSION', '00448459761','cch_engineandtransmission@rdsbh.com'),
    (1, 'ELECTRICAL SYSTEMS', '00442358765', 'cch_electricalsystems@rdsbh.com'),
    (1, 'BODYWORK AND PAINTING', '00447693424', 'cch_bodyworkandpainting@rdsbh.com'),
    (1, 'GENERAL MAINTENANCE', '00442850376', 'cch_generalmaintenance@rdsbh.com'),
    (2, 'CUSTOMER SERVICE', '0044760342', 'cch_customer_service@rdsbh.com'),
    (2, 'FINANCE', '00447603426','cch_finance@rdsbh.com');

INSERT INTO service (dept_id, service_name, service_description, service_duration, service_cost)
VALUES
    (1, 'Engine Repair', 'The pump and filters will be replaced, and the oil will be topped up.', 2.0, 800.00),
    (1, 'Transmission Fluid Replacement', 'The transmission fluid will be replaced, and the transmission system will be checked for leaks.', 0.5, 200.0),
    (2, 'Relay Replacement', 'The relay where the problem is located will be replaced.', 1.5, 100.00),
    (2, 'Battery Replacement' , 'The battery will be replaced with a new part.', 3.5, 200.00),
    (3, 'Dent Removal and Painting', 'The dents will be removed, and the affected areas will be repainted to restore the vehicle s original appearance.', 6.0, 500.00),
    (3, 'Pedal Box Replacement', 'The pedal box will be cut out and replaced with a new part.', 3.5, 300.00),
    (3, 'Painting', 'The desired part will be painted.', 4.0, 300.00),
    (4, 'Diagnostic Services', 'Specialized tools and equipment will be used to identify issues and malfunctions within the vehicle s systems.', 1.0, 100.00),
    (4, 'Tire Rotation and Balancing', 'The tires will be rotated and balanced.', 1.0, 30.00);

INSERT INTO location (dept_id, location_addr1, location_addr2, location_city, location_postcode)
VALUES
    (1, 'London Road', '149', 'Portsmouth', 'PO183DV'),
    (2, 'London Road', '148', 'Portsmouth', 'PO183DV'),
    (3, 'London Road', '150', 'Portsmouth', 'PO183DV'),
    (3, 'Long Road', '10', 'Havant', 'PO156HH'),
    (4, 'London Road', NULL,'Portsmouth', 'PO184DV'),
    (5, 'London Road', '152', 'Portsmouth', 'PO184DV'),
    (6, 'London Road', '153', 'Portsmouth', 'PO184DV');

INSERT INTO staff (dept_id, role_id, staff_first_name, staff_mid_name, staff_last_name, staff_addr1, staff_addr2, staff_city, staff_postcode, staff_phone, staff_personal_email, staff_business_email, staff_date_joined)
VALUES
    (1, 5, 'Magdalène', 'Gardie', 'Gooch', '1524 Debs Trail', 'Suite 60', 'Alemanguan', '3524', '8425902673', 'ggooch0@free.fr', 'ggooch0@upenn.edu', '2024-12-24'),
    (1, 5, 'Styrbjörn', 'Jed', 'Dunklee', '42598 Prairieview Terrace', 'Suite 80', 'Thị Trấn Văn Quan', '23545', '6252853103', 'jdunklee1@rambler.ru', 'jdunklee1@comcast.net', '2024-02-24'),
    (1, 5, 'Anaïs', 'Allin', 'Denk', '1 Waxwing Park', 'Suite 9', 'Grabów', '99150', '678911639', 'adenk2@parallels.com', 'adenk2@newyorker.com', '2023-10-21'),
    (1, 5, 'Lài', 'Dotti', 'Rivaland', '6176 Hauk Hill', 'Apt 995', 'Bangangté', '2345', '8524134572', 'drivaland3@squarespace.com', 'drivaland3@alexa.com', '2024-09-16'),
    (1, 5, 'Yè', 'Margit', 'Timperley', '3 Reinke Crossing', 'Suite 93', 'Dundrum', '34654', '7482713135', 'mtimperley4@netlog.com', 'mtimperley4@google.com.br', '2024-04-18'),
    (2, 6, 'Mélissandre', 'Abra', 'Volage', '64 Jana Court', '2nd Floor', 'Binitayan', '5504', '4726899942', 'avolage5@furl.net', 'avolage5@wordpress.org', '2024-12-10'),
    (2, 6, 'Hélèna', 'Anjanette', 'Savine', '9897 Sunnyside Court', 'Room 1048', 'Haugesund', '5532', '4681824587', 'asavine6@oracle.com', 'asavine6@unicef.org', '2024-11-06'),
    (2, 6, 'Amélie', 'Bernardo', 'Camamill', '9 Raven Street', NULL, 'Fornos de Algodres', '105', '6011708470', 'bcamamill7@newsvine.com', 'bcamamill7@hud.gov', '2024-10-05'),
    (2, 6, 'Agnès', 'Berte', 'Cammiemile', '88588 Spaight Alley', 'Apt 1780', 'Carapo', '2345', '9227889640', 'bcammiemile8@mediafire.com', 'bcammiemile8@spotify.com', '2024-01-03'),
    (2, 6, 'Jú', 'Gage', 'Malthus', '3134 Debra Avenue', '15th Floor', 'Foluo', '765', '9757093466', 'gmalthus9@wikispaces.com', 'gmalthus9@columbia.edu', '2022-01-08'),
    (3, 7, 'Daphnée', 'Debee', 'Flaonier', '42199 Del Sol Junction', '15th Floor', 'Hilotongan', '3201', '1472183674', 'dflaoniera@hugedomains.com', 'dflaoniera@chronoengine.com', '2023-03-12'),
    (3, 7, 'Maëlla', 'Alvera', 'Epelett', '07 Spenser Plaza', 'Apt 1543', 'Bunol', '3115', '2592869379', 'aepelettb@google.com.hk', 'aepelettb@census.gov', '2024-07-24'),
    (3, 7, 'Maëlyss', 'Finn', 'Di Iorio', '16 Transport Junction', 'PO Box 61488', 'Senadan', '1358', '9595647799', 'fdiiorioc@discovery.com', 'fdiiorioc@sitemeter.com', '2023-12-13'),
    (3, 7, 'Mélys', 'Cherey', 'Alekhov', '3896 Coolidge Junction', 'PO Box 97944', 'Porto Feliz', '1854', '7567622487', 'calekhovd@icq.com', 'calekhovd@uol.com.br', '2012-12-27'),
    (3, 7, 'Marie-ève', 'Patten', 'Vanyushkin', '1 Thompson Pass', 'Apt 1810', 'Amherst', 'B4H', '6696615509', 'pvanyushkine@blogtalkradio.com', 'pvanyushkine@pagesperso-orange.fr', '2024-10-17'),
    (4, 8, 'Håkan', 'Sergeant', 'Boecke', '1260 Burning Wood Terrace', 'Apt 1861', 'Göteborg', '4122', '9608994915', 'sboeckef@fema.gov', 'sboeckef@ihg.com', '2014-10-18'),
    (4, 8, 'Daphnée', 'Tybie', 'Scurr', '164 Prairie Rose Center', 'Room 1444', 'Prabuty', '82-550', '4532280068', 'tscurrg@boston.com', 'tscurrg@prweb.com', '2024-12-12'),
    (4, 8, 'Athéna', 'Laurette', 'Yanukhin', '2119 Buell Road', 'PO Box 81871', 'Maba', '945', '1917855076', 'lyanukhinh@qq.com', 'lyanukhinh@netlog.com', '2024-05-11'),
    (4, 8,'Björn', 'Esdras', 'Isakov', '1707 Holy Cross Park', 'Suite 42', 'Picos', '646000', '4812108210', 'eisakovi@bing.com', 'eisakovi@deviantart.com', '2024-06-10'),
    (4, 8, 'Daphnée', 'Car', 'Dunnet', '032 Declaration Park', '4th Floor', 'Zhoukou', '68537', '5728979207', 'cdunnetj@yahoo.com', 'cdunnetj@businesswire.com', '2016-12-04'),
    (5, 9, 'Intéressant', 'Ephrem', 'Chittem', '990 Carpenter Lane', 'Apt 1324', 'Jintao', '4734', '4394006777', 'echittemk@columbia.edu', 'echittemk@sogou.com', '2024-10-08'),
    (5, 9, 'Björn', 'Larisa', 'Widdows', '5697 Monica Street', 'Room 1975', 'Piracaia', '70-000', '1134548400', 'lwiddowsl@ucoz.ru', 'lwiddowsl@about.com', '2024-12-23'),
    (6, 10, 'Mén', 'Cleo', 'Bonifazio', '64 Scott Terrace', 'Suite 63', 'Banjar Mambalkajanan', '7934', '7196370295', 'cbonifaziom@g.co', 'cbonifaziom@mysql.com', '2024-01-24'),
    (1, 1, 'Göran', 'Ivie', 'Tourner', '16568 Moulton Court', 'PO Box 70507', 'Swiętajno', '19411', '7223337718', 'itournern@sphinn.com', 'itournern@behance.net', '2018-02-12'),
    (2, 2, 'Tán', 'Ansley', 'Constanza', '0 Mcbride Court', 'Apt 1516', 'Vári', '3635', '5857875211', 'aconstanzao@odnoklassniki.ru', 'aconstanzao@whitehouse.gov', '2024-08-09'),
    (3, 3, 'Adélaïde', 'Ulberto', 'Grief', '0003 Homewood Center', 'Apt 1624', 'Argir', '165', '2699793801', 'ugriefp@domainmarket.com', 'ugriefp@dedecms.com', '2024-08-10'),
    (4, 4, 'Yú', 'Maurie', 'Kindred', '1063 Menomonie Street', 'Room 1868', 'Dundrum', 'D6W', '5741018146', 'mkindredq@icio.us', 'mkindredq@stumbleupon.com', '2024-02-15');

INSERT INTO staff_qualification (qual_id, staff_id, acquired_date, exp_date)
VALUES
    (1, 1, '2023-09-20', NULL),
    (1, 2, '2023-04-10', NULL),
    (1, 3, '2023-10-22', NULL),
    (1, 4, '2023-12-28', NULL),
    (1, 5, '2024-08-19', NULL),
    (1, 6, '2025-01-10', NULL),
    (1, 7, '2023-03-13', NULL),
    (1, 8,'2023-08-19', NULL),
    (1, 9, '2024-05-28', NULL),
    (1, 10, '2024-04-16', NULL),
    (1, 11, '2024-02-24', NULL),
    (1, 12, '2024-04-30', NULL),
    (1, 13, '2023-08-14', NULL),
    (1, 14, '2025-01-10', NULL),
    (1, 15, '2024-05-03', NULL),
    (1, 16, '2023-03-17', NULL),
    (1, 17, '2025-01-31', NULL),
    (1, 18, '2023-09-06', NULL),
    (1, 19, '2023-11-09', NULL),
    (1, 20, '2024-01-02', NULL),
    (1, 21, '2025-03-02', NULL),
    (1, 22, '2023-06-09', NULL),
    (1, 23, '2023-02-17', NULL),
    (1, 24, '2023-09-07', NULL),
    (1, 25, '2023-08-13', NULL),
    (1, 26, '2023-10-25', NULL),
    (1, 27, '2023-08-26', NULL),
    (2, 24, '2023-05-31', '2025-05-31'),
    (2, 25, '2023-03-19', '2025-03-19'),
    (2, 26, '2024-09-23', '2026-09-23'),
    (2, 27, '2023-03-28', '2025-03-28'),
    (3, 24, '2023-05-12', '2028-05-12'),
    (3, 25, '2023-03-15', '2028-03-15'),
    (3, 26, '2024-03-12', '2029-03-12'),
    (3, 27, '2024-07-24', '2029-07-24');

INSERT INTO car (cust_id, car_reg, car_make, car_model, car_colour, car_last_mot)
VALUES
    (1, '2C546136', 'Mercedes', 'Classic', 'Mauv', '2/25/2024'),
    (2, 'WBR14654', 'Chevrolet', 'Silverado 1500', 'Turquoise', '6/10/2024'),
    (2, '1A501196', 'Seat', 'Lucerne', 'Yellow', '4/27/2024'),
    (3, 'JTHBB1BA', 'Mercedes', 'Integra', 'Aquamarine', '2/8/2024'),
    (4, 'SCBBR53W', 'Audi', 'Mustang', 'Goldenrod', '7/21/2024'),
    (5, '5N1AA0ND', 'Seat', 'Legacy', 'Red', '10/22/2024');

INSERT INTO booking (car_id, location_id, booking_status, booking_comments, booking_booked)
VALUES
    (1, 1, 'Complete', NULL, '2024-10-12'),
    (2, 2, 'Scheduled', NULL, '2025-02-20'),
    (3, 3, 'Scheduled', NULL, '2025-02-23'),
    (4, 3, 'Complete', NULL, '2025-01-08'),
    (5, 5, 'Scheduled', NULL, '2025-02-21'),
    (6, 5, 'Complete', 'The client needs the car on evening', '2024-12-01');

INSERT INTO service_detail (serv_det_id, booking_id, service_id, staff_id, part_id, serv_det_part_qty, serv_det_date, serv_det_start, serv_det_end, serv_det_add_cost, serv_det_report_date, serv_det_notes)
VALUES
    (1, 1, 1, 3, 1, 1, '2024-10-15', '13:00:00', '13:30:00', NULL, '2024-10-12', 'The engine needs to be repaired by replacing the pump and filters. It is also necessary to top up the oil.'),
    (2, 1, 1, 3, 2, 1, '2024-10-15', '13:30:00', '16:30:00', NULL, '2024-10-12', 'The engine needs to be repaired by replacing the pump and filters. It is also necessary to top up the oil.'),
    (3, 1, 1, 3, 3, 1, '2024-10-15', '16:30:00', '18:00:00', NULL, '2024-10-12', 'The engine needs to be repaired by replacing the pump and filters. It is also necessary to top up the oil.'),
    (4, 2, 3, 8, 4, 1, '2025-03-01', '14:00:00', '15:30:00', NULL, '2025-02-20', 'The relay for the right-side indicator needs to be replaced.'),
    (1, 3, 5, 13, 5, 1, '2025-03-02', '10:00:00', '14:00:00', NULL, '2025-02-23', 'The right-side door has scratches that need to be sanded. Afterwards, it needs to be painted in the original color, red.'),
    (2, 3, 5, 13, 6, 1, '2025-03-02', '14:00:00', '16:00:00', NULL, '2025-02-23', 'The right-side door has scratches that need to be sanded. Afterwards, it needs to be painted in the original color, red.'),
    (1, 4, 7, 15, 5, 1, '2025-01-08', '08:30:00', '12:30:00', NULL, '2025-01-08', 'A complete color change from blue to white is desired.'),
    (2, 4, 7, 15, 6, 1, '2025-01-08', '12:30:00', '13:00:00', NULL, '2025-01-08', 'A complete color change from blue to white is desired.'),
    (1, 5, 8, 18, NULL, NULL, '2025-02-22', '12:00:00', '13:00:00', NULL, '2025-02-21', 'The customer heard a strange noise during braking and requests a vehicle diagnosis.'),
    (1, 6, 9, 20, NULL, NULL, '2024-12-07', '11:00:00', '12:00:00', NULL, '2024-12-01', 'The customer wants tire rotation and balancing.');

INSERT INTO invoice (booking_id, inv_description, inv_created_at, inv_total, inv_payment_due, inv_instalments)
VALUES
    (1, 'The customer needs to pay £800.0 for labor and £700.0 for parts, totaling £1500.0. The customer wants to pay in a single installment.', '2024-10-12', 1500.0, '2024-10-12', 1),
    (4, 'The customer needs to pay £300.0 for labor and £500.0 for parts, totaling £800.0. The customer wants to pay in a single installment.', '2025-01-08', 800.0, '2025-01-08', 1),
    (6, 'The customer needs to pay £30.0 for labor and £200.0 for parts, totaling £230.0. The customer wants to pay in two installments.', '2024-12-07', 230.0, '2025-01-07', 2);

INSERT INTO payment (inv_id, pay_method_id, payment_instal_no, payment_amount, payment_date, payment_time)
VALUES
    (1, 2, 1, 1500.0, '2024-10-12', '11:39:44'),
    (2, 1, 2, 800.0, '2025-01-08', '13:28:40'),
    (3, 1, 3, 115.0, '2024-12-07', '16:18:01'),
    (3, 1, 3, 115.0, '2025-01-01', '10:17:17');

INSERT INTO feedback (cust_id, feedback_created_at, feedback_text)
VALUES
    (1, '2024-10-22', 'Wonderful services, highly recommend.'),
    (3, '2025-01-11', 'They resolved my issues very quickly and at an excellent price. Very satisfied!'),
    (5, '2024-12-12', 'Wonderful staff and quality services. Highly recommend.');