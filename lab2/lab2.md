# Лабораторна робота №2
### Мета роботи: 
Перетворити ER-діаграму предметної області у реляційну схему та її реалізація у СУБД PostgreSQL

## Опис структури бази даних

Таблиця `doctor_specialization`
* `spec_id`  — унікальний ідентифікатор спеціалізації
* `spec_name` — назва спеціалізації
* `description` — детальний опис спеціалізації

Таблиця `department`
* `department_id` — унікальний ідентифікатор відділення
* `dep_name` — назва відділення
* `floor` — поверх, на якому розташоване відділення

Таблиця `medication`
* `medication_id` — унікальний ідентифікатор препарату
* `med_name` — назва препарату
* `manufacturer` — виробник препарату
* `side_effects` — побічні ефекти
* `restriction` — протипоказання та обмеження

Таблиця `patient`
* `patient_id` — унікальний ідентифікатор пацієнта
* `first_name` — ім'я пацієнта
* `last_name` — прізвище пацієнта
* `date_of_birth` — дата народження
* `phone` — контактний номер телефону
* `city` — місто проживання
* `street` — вулиця
* `building` — номер будинку
* `email` — електронна пошта пацієнта

Таблиця `doctor`
* `doctor_id` — унікальний ідентифікатор лікаря
* `spec_id` — ідентифікатор спеціалізації лікаря
* `dep_id` — ідентифікатор відділення, за яким закріплений лікар
* `first_name` — ім'я лікаря
* `last_name` — прізвище лікаря
* `email` — робоча електронна пошта лікаря
* `phone` — робочий номер телефону лікаря

Таблиця `appointment`
* `appointment_id` — унікальний ідентифікатор запису на прийом
* `patient_id` — ідентифікатор пацієнта, який записався
* `doctor_id` — ідентифікатор лікаря, який прийматиме
* `reason` — причина звернення
* `status` — поточний статус візиту (заплановано, закінчено тощо)
* `start_time` — дата та час початку прийому
* `end_time` — дата та час завершення прийому

Таблиця `prescription`
* `prescription_id` — унікальний номер бланка рецепта
* `appointment_id` — ідентифікатор візиту, під час якого створено рецепт
* `notes` — загальні медичні рекомендації лікаря

Таблиця `prescription_item`
* `item_id` — унікальний ідентифікатор конкретного призначення в рецепті
* `prescription_id` — ідентифікатор загального бланка рецепта
* `medication_id` — ідентифікатор призначеного препарату
* `dosage` — дозування препарату
* `instructions` — інструкція з прийому препарату

## Зв'язки між таблицями

`department` ↔ `doctor` (1:M)
* Одне відділення може мати багато лікарів, але кожен лікар закріплений лише за одним відділенням
* *Реалізація:* FK`dep_id` у таблиці `doctor`

`doctor_specialization` ↔ `doctor` (1:M)
* Одну спеціалізацію можуть мати пару лікарів, але кожен лікар має лише одну спеціалізацію
* *Реалізація:* FK `spec_id` у таблиці `doctor`

`patient` ↔ `appointment` (1:M)
* Один пацієнт може записуватися на прийом багато разів
* *Реалізація:* FK `patient_id` у таблиці `appointment`

`doctor` ↔ `appointment` (1:M)
* Один лікар може проводити багато прийомів для різних пацієнтів
* *Реалізація:* FK `doctor_id` у таблиці `appointment`

`appointment` ↔ `prescription` (1:1)
* Після одного візиту може бути створено максимум один загальний рецепт для лікування
* *Реалізація:* FK `appointment_id` у таблиці `prescription` з додатковим обмеженням `UNIQUE`

`prescription` ↔ `prescription_item` (1:M)
* В одному рецепті може бути декілька препаратів
* *Реалізація:* FK `prescription_id` у таблиці `prescription_item`

`medication` ↔ `prescription_item` (1:M)
* Один медикамент може належати багатьом рецептам
* *Реалізація:* FK `medication_id` у таблиці `prescription_item`

## Обмеження та бізнес-припущення

* Обов'язковість інструкцій до ліків (`NOT NULL`): У таблиці `prescription_item` поле `instructions` є обов'язковим.Для ліків потрібно вказувати не тільки дозування, а й спосіб прийняття .
* Заборона порожніх обмежень для ліків (`NOT NULL`): У таблиці `medication` поле `restriction` є обов'язковим.Майже для всіх ліків існують обмеження. При їх відсутності краще просто в цю графу написати "Відсутньо".
* Опціональність контактних даних (`NULL`): У таблиці `patient` поле `email` не є обов'язковим. Не всі пацієнти мають електронну пошту. 
* Захист від подвійного запису: У таблиці `appointment` встановлено обмеження `UNIQUE (doctor_id, start_time)`.Це захист від подвійного запису на той самий час до лікаря.
* Логіка часу прийому (`CHECK`): У таблиці `appointment` додано обмеження `CHECK (end_time > start_time)`. Це унеможливлює накладання кількох візитів по часові.
* Один візит = Один бланк рецепта: У таблиці `prescription` поле `appointment_id` має обмеження `UNIQUE`. Це гарантує зв'язок 1:1, тобто на один прийом не може бути виписано два різних загальних бланки.
## Реалізація в pgadmin
### Таблиці
```sql
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
```
### insert запити
```sql
insert into doctor_specialization (spec_id, spec_name, description) values
(1, 'Терапевт', 'Лікар першого контакту, лікує загальні захворювання'),
(2, 'Кардіолог', 'Спеціаліст з діагностики та лікування серцево-судинних хвороб'),
(3, 'Нейрохірург', 'Лікар, що спеціалізується на лікуванні звороб та травм центральнох та переверичної нервової системи');


insert into department (department_id, dep_name, floor) values
(1, 'Терапевтичне', 1),
(2, 'Кардіологічне', 2),
(3, 'Нейрохіругрічне', 3);


insert into medication (medication_id, med_name, manufacturer, side_effects, restriction) values
(1, 'Парацетамол', 'Дарниця', 'Рідко можлива алергічна реакція', 'Не більше 4г на добу'),
(2, 'Німесил', 'Berlin-Chemie', 'Біль у шлунку, нудота', 'Тільки для дорослих'),
(3, 'Корвалол', 'Фармак', 'Сонливість, зниження тиску', 'Не вживати з алкоголем');


insert into patient (first_name, last_name, date_of_birth, phone, city, street, building, email) values
('Степан', 'Павлюк', '2003-05-15', '+380501234567', 'Київ', 'Хрещатик', '1', 'stepapv@ukr.net'),
('Валентин', 'Заграйко', '1970-02-25', '+380671234567', 'Київ', 'Свободи', '5', 'valentun970@ukr.net'),
('Ганна', 'Шевченко', '2000-03-09', '+380931234567', 'Київ', 'Дерибасівська', '13', 'ann_shev@gmail.com');


insert into doctor (spec_id, dep_id, first_name, last_name, email, phone) values
(1, 1, 'Олег', 'Коваленко', 'oleg.terapevt@hospital.com', '+380509998801'),
(2, 2, 'Максим', 'Григоренко', 'max.surgeon@hospital.com', '+380509998802'),
(3, 3, 'Анна', 'Бойко', 'anna.cardio@hospital.com', '+380509998803');


insert into appointment (patient_id, doctor_id, reason, status, start_time, end_time) values
(1, 1, 'Висока температура, кашель', 'закінчено', '2026-05-01 10:00', '2026-05-01 10:30'),
(2, 2, 'Біль у грудях', 'заплановано', '2026-05-10 14:00', '2026-05-10 14:30'),
(3, 3, 'Огляд після травми', 'в процесі', '2026-05-06 13:00', '2026-05-06 13:30');


insert into prescription (appointment_id, notes) values
(1, 'Дотримуватися постільного режиму, пити багато рідини'),
(2, 'Уникати стресів та фізичних навантажень'),
(3, 'Пройти реабілітацію, не допускати високого фізичного навантащення протягом 3 місяців');


insert into prescription_item (prescription_id, medication_id, dosage, instructions) values
(1, 1, '500 мг', 'Приймати по 1 таблетці при підвищенні температури вище 38.5 градусів.'),
(2, 2, '1 пакетик (100 мг)', 'Розчинити у теплій воді. Пити 2 рази на добу для зняття болю в коліні.'),
(3, 3, '20 крапель', 'Розчинити у 50 мл води. Приймати під час нападів тахікардії.');
```
## Результати роботи скриптів
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20182521.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183101.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183122.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183140.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183329.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183347.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183406.png)
![]( https://github.com/Fireolll/dblabs/blob/main/lab2/Screenshot%202026-05-06%20183444.png)
