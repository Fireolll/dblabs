# Лабораторна робота №5

## Мета: аналіз, покращення та нормалізація вже створеної бази даних для запису до лікарів

## Аналіз початкової схеми та вирішення виявлених проблем:
Таблиця `doctor_specialization`:
```sql
create table doctor_specialization(
	spec_id integer primary key,
	spec_name varchar(28) not null,
	description text
);
```

#### Функціональні зв'язки:
`spec_id → spec_name, description`

Таблиця `department`:
```sql
create table department(
	department_id integer primary key,
	dep_name varchar(20) not null,
	floor smallint not null
);
```
#### Функціональні зв'язки:
`department_id → dep_name, floor`

Таблиця `doctor`:
```sql
create table doctor(
	doctor_id serial primary key,
	spec_id integer references doctor_specialization(spec_id) not null,
	dep_id integer references department(department_id) not null,
	first_name varchar(15) not null,
	last_name varchar (15) not null,
	email varchar (30) not null,
	phone varchar (13) not null
);
```
#### Функціональні зв'язки:
`doctor_id → spec_id, dep_id, first_name, last_name, email, phone`

Таблиця `appointment` (з `appointment_status`):
```sql
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
```
#### Функціональні зв'язки:
`appointment_id → patient_id, doctor_id, reason, status, start_time, end_time`

Також через обмеження `unique` `(doctor_id, start_time)`:

`(doctor_id, start_time) → patient_id, reason, status, end_time`

Таблиця `prescription`:
```sql
create table prescription(
	prescription_id serial primary key not null,
	appointment_id integer unique references appointment(appointment_id) not null,
	notes text
);
```
#### Функціональні зв'язки:
`prescription_id → appointment_id, notes`

Також через обмеження `unique`:

`appointment_id → notes`

Таблиця `prescription_item`:
```sql
create table prescription_item(
	item_id serial primary key not null,
	prescription_id integer references prescription(prescription_id) not null,
	medication_id integer references medication(medication_id) not null,
	dosage varchar(20) not null,
	instructions text not null
);
```
#### Функціональні зв'язки:
`item_id → prescription_id, medication_id, dosage, instructions`

---    
## Виявлені проблеми в початковій, ненормалізованій схемі:

#### Таблиця medication
* Порушення 1NF (Неатомарні атрибути): Стовпці `side_effects` та `restriction` зберігають текст,який може містити кілька побічних ефектів(наприклад:нудота, головний біль, сонливість).

#### Структура таблиці medicatin: 
``` sql
create table medication(
	medication_id integer primary key,
	med_name varchar (20) not null,
	manufacturer varchar (15) not null,
	side_effects text not null,
	restriction text not null
);
```

#### Функціональні зв'язки:
`medication_id → med_name, manufacturer, side_effects, restriction`
* `side_effects` - не атомарний атрибут: може містити перелік значень (наприклад: "нудота, головний біль, сонливість"), що порушує 1NF.
* `restriction` - не атомарний атрибут: може містити перелік значень (наприклад: "вагітність, діти до 12 років"), що порушує 1NF.

#### Таблиця patient
* Варто додати практичну нормалізацію для `city`
#### Структура таблиці patient: 
``` sql
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
```

#### Функціональні зв'язки
* `patient_id -> first_name, last_name, date_of_birth, phone, email, street, building, city` (Повна функціональна залежність).

### Додаткові знайдені проблеми:

Таблиця `patient` технічно перебуває у 3NF - атрибут `city` напряму залежить від `patient_id`, транзитивної залежності немає. Але є ризик. При заповнені бд назви міст будуть повторюватися і якщо місто переіменують, доведеться змінювати надзвичайно великій кількості пацієнтів його. Для усунення цього ризику `city` винесено в окрему таблицю.

така ж ситуація з `manufacturer` у таблиці `medication`: атрибут напряму залежить від `medication_id`, але при великій кількості ліків одного виробника його назва дублюватиметься. Виносимо `manufacturer` в окрему довідникову таблицю для уникнення аномалій оновлення.

Тобто, фактично всі талиці,окрім `medication`. перебувають в 3NF.

---
## Перехід до нормалізації

### Перехід до 1NF

Таблиця `medication` містить багатозначні атрибути.

Стан таблиці змін:
`medication (medication_id, med_name, manufacturer, side_effects, restriction)`

`side_effects` та `restriction` можуть зберігати кілька значень в одному
полі - це порушення 1NF.

Щоб це виправити виносимо багатозначні атрибути в окремі таблиці.

Стан таблиць після 1NF:
* `medication (medication_id, med_name, manufacturer)`
* `medication_side_effect (side_effect_id, medication_id, effect_description)`
* `medication_restriction (restriction_id, medication_id, restriction_description)`

### Перехід до 2NF

У всіх таблицях схеми первинний ключ є простим (не складеним),
тому часткові залежності неможливі за визначенням.

Перевірка кожної таблиці після 1NF:

* `medication (medication_id PK, med_name, manufacturer)` - усі атрибути залежать від `medication_id`. 
* `medication_side_effect (side_effect_id PK, medication_id FK, effect_description)` - усі атрибути залежать від `side_effect_id`. 
* `medication_restriction (restriction_id PK, medication_id FK, restriction_description)` - усі атрибути залежать від `restriction_id`. 
* `patient (patient_id PK, first_name, last_name, date_of_birth, phone, email, city, street, building)` - усі атрибути залежать від `patient_id`. 
* Решта таблиць (`doctor`, `appointment`, `prescription`, `prescription_item`, `doctor_specialization`, `department`) - прості ключі, всі атрибути залежать від PK. 

### Перехід до 3NF

Проблема: таблиці `medication` та `patient` не мають транзитивних залежностей у класичному розумінні, але містять атрибути (`manufacturer`,`city`), які при внесенні в них великої кількості даних будуть дублюватися та можуть створиити аномалії оновлення. ТОму я виніс їх в окремі таблиці

Стан таблиць до змін:
* `medication (medication_id, med_name, manufacturer)`
* `patient (patient_id, first_name, last_name, date_of_birth, phone, email, city, street, building)`

Стан таблиць після змін:
* `manufacturer (manufacturer_id, manufacturer_name)`
* `city (city_id, city_name)`
* `medication (medication_id, med_name, manufacturer_id FK)`
* `patient (patient_id, first_name, last_name, date_of_birth, phone, email, city_id FK, street, building)`

---
## SQL скрипти для нормалізованих таблиць
``` sql
drop table if exists medication_side_effect cascade;
drop table if exists medication_restriction cascade;
drop table if exists prescription_item cascade;
drop table if exists prescription cascade;
drop table if exists appointment cascade;
drop type if exists appointment_status cascade;
drop table if exists doctor cascade;
drop table if exists patient cascade;
drop table if exists medication cascade;
drop table if exists manufacturer cascade;
drop table if exists city cascade;
drop table if exists department cascade;
drop table if exists doctor_specialization cascade;

create table city(
	city_id serial primary key,
	city_name varchar(20) not null unique
);

create table manufacturer(
	manufacturer_id serial primary key,
	manufacturer_name varchar(20) not null unique
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
    med_name varchar(50) not null,
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
```
## ER діаграма для нормалізованої бд
![](https://github.com/Fireolll/dblabs/blob/main/lab5/ERDnormal.png)
