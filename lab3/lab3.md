# Лабораторна робота №3 
## Мета : Виконання запитів для додавання (INSERT), вибірки (SELECT), оновлення (UPDATE) та видалення (DELETE) даних, щоб протестувати реляційну базу даних нашої відеогри.

## Реалізація в pgadmin
``` sql
insert into patient (first_name, last_name, date_of_birth, phone, city, street, building, email) values
('Маруся', 'Стефаник', '2001-09-12', '+380501268567', 'Київ', 'Академіка Янгеля', '7', 'maru_stef@ukr.net'),
('Тарас', 'Гапоник', '1999-10-01', '+380505678245', 'Київ', 'Борщагівська', '10', 't.gap99@gmail.com');

delete from patient 
where patient_id = 3;

update patient 
set phone = '+380682294500', email = 'stepapv@gmail.com'
where patient_id = 1;

select first_name,last_name,city 
from patient;
```
## Результат роботи скрипту
![](https://github.com/Fireolll/dblabs/blob/main/lab3/Screenshot%202026-05-06%20205014.png)
![](https://github.com/Fireolll/dblabs/blob/main/lab3/Screenshot%202026-05-06%20205127.png)
