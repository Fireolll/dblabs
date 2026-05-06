# Лабораторна робота 4
## Мета: Використання агрегатних функцій, групування даних та об'єднання таблиць (JOIN) для підсумовування тенденцій, створення зведеної статистики та аналізу даних реляційної бази даних.

## Реалізація в pgadmin
``` sql
select doctor_id, count(appointment_id) as total_appointments
from appointment
group by doctor_id
order by total_appointments desc;

select city, count(patient_id) as patient_count
from patient
group by city
order by patient_count desc;

select 
    min(start_time) as earliest_appointment, 
    max(start_time) as latest_appointment
from appointment;

select manufacturer, count(medication_id) as meds_count
from medication
group by manufacturer;

select 
    p.first_name || ' ' || p.last_name as patient_name,
    d.first_name || ' ' || d.last_name as doctor_name,
    a.start_time, 
    a.status
from appointment a
inner join patient p on a.patient_id = p.patient_id
inner join doctor d on a.doctor_id = d.doctor_id;

select 
    ds.spec_name, 
    d.first_name, 
    d.last_name
from doctor_specialization ds
left join doctor d on ds.spec_id = d.spec_id;

select 
    a.appointment_id, 
    a.reason, 
    p.prescription_id, 
    p.notes
from prescription p
right join appointment a on p.appointment_id = a.appointment_id;

select first_name, last_name, date_of_birth
from patient
where date_of_birth = (
    select min(date_of_birth) 
    from patient
);

select 
    first_name, 
    last_name,
    (select count(*) from appointment a where a.doctor_id = d.doctor_id) as total_appointments
from doctor d;

select city, count(patient_id) as patient_count
from patient
group by city
having count(patient_id) >= (
    select avg(city_count)
    from (
        select count(patient_id) as city_count 
        from patient 
        group by city
    ) as subquery
);
```
## Опис запитів:
Запити з агрегаційними функціями
* Завантаженість лікарів (`COUNT`, `GROUP BY`): Рахує кількість візитів у кожного лікаря.
* Географія пацієнтів (`COUNT`, `GROUP BY`): Показує, скільки пацієнтів звертається до клініки з кожного міста.
* Хронологія візитів (`MIN`, `MAX`): Визначає дати першого та останнього запису на прийом у системі.
* Аналіз ліків (`COUNT`, `GROUP BY`): Рахує, скільки препаратів від кожного виробника є в довіднику медикаментів.

Запити з використанням `JOIN`
* Деталізація візитів (`INNER JOIN`): Виводить  імена лікарів та пацієнтів разом із часом прийому.
* Аудит спеціалізацій (`LEFT JOIN`): Показує всі медичні спеціалізації з бази, навіть якщо на цю посаду тимчасово не найнято жодного лікаря.
* Візити без рецептів (`RIGHT JOIN`): Допомагає швидко знайти візити, після яких пацієнту не виписали жодного призначення.

Запити з підзапитами
* Підзапит у (`WHERE`): Знаходить ім'я та прізвище найстарішого пацієнта клініки.
* Підзапит у (`SELECT`): Виводить список лікарів і для кожного автоматично підраховує загальну кількість його прийомів.
* Підзапит у (`HAVING`): Знаходить міста, з яких приїжджає більше пацієнтів, ніж у середньому по всіх містах.

## Результати запитів:
![перший запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20212755.png)

![другий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20212847.png)

![третій запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20212922.png)

![четвертий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20212937.png)

![п'ятий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20212951.png)

![шостий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20213004.png)

![сьомий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20213027.png)

![восьмий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20213045.png)

![дев'ятий запит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20213105.png)

![десятий щапит](https://github.com/Fireolll/dblabs/blob/main/lab4/Screenshot%202026-05-06%20213120.png)
