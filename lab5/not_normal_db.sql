create table doctor_specialization(
	spec_id integer primary key,
	spec_name varchar(28) not null,
	description text
);
create table department(
	department_id integer primary key,
	dep_name varchar(20) not null,
	floor smallint not null
);
create table patient(
	patient_id serial primary key,
	first_name varchar(15) not null,
	last_name varchar (15) not null,
	date_of_birth date not null,
	phone varchar (13) not null,
	city varchar (20) not null,
	street varchar(25) not null,
	building varchar (4) not null,
	email varchar (30)
);
create table medication(
	medication_id integer primary key,
	med_name varchar (20) not null,
	manufacturer varchar (15) not null,
	side_effects text not null,
	restriction text not null
);
create table doctor(
	doctor_id serial primary key,
	spec_id integer references doctor_specialization(spec_id) not null,
	dep_id integer references department(department_id) not null,
	first_name varchar(15) not null,
	last_name varchar (15) not null,
	email varchar (30) not null,
	phone varchar (13) not null
);
create type appointment_status as enum('заплановано','закінчено','відмінено','в процесі');
create table appointment(
	appointment_id serial primary key not null,
	patient_id integer references patient(patient_id) not null,
	doctor_id integer references doctor(doctor_id) not null,
	reason text not null,
	status appointment_status not null,
	start_time timestamp not null,
	end_time timestamp not null,
	check (end_time > start_time),
	unique (doctor_id, start_time)
);
create table prescription(
	prescription_id serial primary key not null,
	appointment_id integer unique references appointment(appointment_id) not null,
	notes text
);
create table prescription_item(
	item_id serial primary key not null,
	prescription_id integer references prescription(prescription_id) not null,
	medication_id integer references medication(medication_id) not null,
	dosage varchar(20) not null,
	instructions text not null
);
