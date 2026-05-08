create table city(
	city_id serial primary key,
	city_name varchar(20) not null unique
);

create table manufacturer(
	manufacturer_id serial primary key,
	manuf_name varchar(30) not null unique
);

create table department (
    department_id integer primary key,
    dep_name varchar(20) not null,
    floor smallint not null
);

create table doctor_specialization (
    spec_id integer primary key,
    spec_name varchar(28) not null,
    description text
);

create table patient (
    patient_id serial primary key,
    first_name varchar(15) not null,
    last_name varchar(15) not null,
    date_of_birth date not null,
    phone varchar(13) not null,
    email varchar(30),
    city_id integer references city(city_id) not null,
    street varchar(25) not null,
    building varchar(4) not null
);

create table medication (
    medication_id integer primary key,
    med_name varchar(30) not null,
    manufacturer_id integer references manufacturer(manufacturer_id) not null
);

create table doctor (
    doctor_id serial primary key,
    spec_id integer references doctor_specialization(spec_id) not null,
    dep_id integer references department(department_id) not null,
    first_name varchar(15) not null,
    last_name varchar(15) not null,
    email varchar(30) not null,
    phone varchar(13) not null
);

create type appointment_status as enum('заплановано', 'закінчено', 'відмінено', 'в процесі');

create table appointment (
    appointment_id serial primary key,
    patient_id integer references patient(patient_id) not null,
    doctor_id integer references doctor(doctor_id) not null,
    reason text not null,
    status appointment_status not null,
    start_time timestamp not null,
    end_time timestamp not null,
    check (end_time > start_time),
    unique (doctor_id, start_time)
);

create table prescription (
    prescription_id serial primary key,
    appointment_id integer unique references appointment(appointment_id) not null,
    notes text
);

create table prescription_item (
    item_id serial primary key,
    prescription_id integer references prescription(prescription_id) not null,
    medication_id integer references medication(medication_id) not null,
    dosage varchar(20) not null,
    instructions text not null
);


create table medication_side_effect (
    side_effect_id serial primary key,
    medication_id integer references medication(medication_id) not null,
    effect_description text not null
);

create table medication_restriction (
    restriction_id serial primary key,
    medication_id integer references medication(medication_id) not null,
    restriction_description text not null
);
