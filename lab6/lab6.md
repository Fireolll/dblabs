# Лабораторна робота №6

## Мета: провести міграцію бд для запису до лікаря через Prisma ORM

## Додавання нової таблиці treatment_plan
```sql
// нова таблиця для плану лікування пацієнтів
model treatment_plan {
  treatment_id  Int           @id @default(autoincrement())
  title         String        @db.VarChar(100) 
  description   String        @db.Text         
  duration_days Int?                 
  appointments  appointment[] 
}
// додано FK в таблицю appointment для звязку з tretment_plan
model appointment {
  appointment_id Int                @id @default(autoincrement())
  patient_id     Int
  doctor_id      Int
  reason         String
  status         appointment_status
  start_time     DateTime           @db.Timestamp(6)
  end_time       DateTime           @db.Timestamp(6)
  doctor         doctor             @relation(fields: [doctor_id], references: [doctor_id], onDelete: NoAction, onUpdate: NoAction)
  patient        patient            @relation(fields: [patient_id], references: [patient_id], onDelete: NoAction, onUpdate: NoAction)
  prescription   prescription?
  @@unique([doctor_id, start_time])
  treatment_id   Int? 
  treatment treatment_plan? @relation(fields:[treatment_id], references: [treatment_id])
}
```
## Зміни в вже існуючих таблицях
* додавання статусу роботи лікарів через `is_active` в таблиці `doctor`
* видалення опису спеціалізації лікаря в таблиці `doctor_specialization`
Таблиця `doctor`
До змін:
```sql
model doctor {
  doctor_id             Int                   @id @default(autoincrement())
  spec_id               Int
  dep_id                Int
  first_name            String                @db.VarChar(15)
  last_name             String                @db.VarChar(15)
  email                 String                @db.VarChar(30)
  phone                 String                @db.VarChar(13)
  appointment           appointment[]
  department            department            @relation(fields: [dep_id], references: [department_id], onDelete: NoAction, onUpdate: NoAction)
  doctor_specialization doctor_specialization @relation(fields: [spec_id], references: [spec_id], onDelete: NoAction, onUpdate: NoAction)
}
```
Після:
```sql
model doctor {
  doctor_id             Int                   @id @default(autoincrement())
  spec_id               Int
  dep_id                Int
  first_name            String                @db.VarChar(15)
  last_name             String                @db.VarChar(15)
  email                 String                @db.VarChar(30)
  phone                 String                @db.VarChar(13)
  appointment           appointment[]
  department            department            @relation(fields: [dep_id], references: [department_id], onDelete: NoAction, onUpdate: NoAction)
  doctor_specialization doctor_specialization @relation(fields: [spec_id], references: [spec_id], onDelete: NoAction, onUpdate: NoAction)
  is_active Boolean @default(true)
}
```
![](https://github.com/Fireolll/dblabs/blob/main/lab6/doctor_changes.png)

Таблиця `doctor_specialization`
До змін:
```sql
model doctor_specialization {
  spec_id     Int      @id
  spec_name   String   @db.VarChar(28)
  description String? @db.Text
  doctor      doctor[]
}
```
Після:
```sql
model doctor_specialization {
  spec_id     Int      @id
  spec_name   String   @db.VarChar(28)
  doctor      doctor[]
}
```
![](https://github.com/Fireolll/dblabs/blob/main/lab6/doc_spec_changes.png)
# Перевірка роботи оновленої схеми
Для перевірки змін у базі даних я написав скрипт який зчитує та видає дані з самої БД у вигляді json файлу
```json
Отримання даних з бази...

[
  {
    appointment_id: 1,
    patient_id: 1,
    doctor_id: 1,
    reason: 'Кашель',
    status: 'FINISHED',
    start_time: 2026-05-01T07:00:00.000Z,
    end_time: 2026-05-01T07:30:00.000Z,
    treatment_id: 4,
    patient: { first_name: 'Степан', last_name: 'Павлюк' },
    doctor: { first_name: 'Олег', last_name: 'Коваленко', is_active: true },
    treatment: {
      treatment_id: 4,
      title: 'Відпочинковий режим',
      description: "Постільний режим, вживання великої кількості теплої рідини, давати відпочинок голосовим зв'язкам",
      duration_days: 14
    }
  },
  {
    appointment_id: 2,
    patient_id: 2,
    doctor_id: 2,
    reason: 'Біль у грудях',
    status: 'PLANNED',
    start_time: 2026-05-10T11:00:00.000Z,
    end_time: 2026-05-10T11:30:00.000Z,
    treatment_id: 2,
    patient: { first_name: 'Валентин', last_name: 'Заграйко' },
    doctor: { first_name: 'Максим', last_name: 'Григоренко', is_active: true },
    treatment: {
      treatment_id: 2,
      title: 'Дієта',
      description: 'Відсутність жареної, жирної їжі. Більше овочів в харчуванні',
      duration_days: 30
    }
  },
  {
    appointment_id: 3,
    patient_id: 3,
    doctor_id: 3,
    reason: 'Перелом руки',
    status: 'IN_PROCESS',
    start_time: 2026-05-06T10:00:00.000Z,
    end_time: 2026-05-06T10:30:00.000Z,
    treatment_id: 3,
    patient: { first_name: 'Маруся', last_name: 'Стефаник' },
    doctor: { first_name: 'Анна', last_name: 'Бойко', is_active: true },
    treatment: {
      treatment_id: 3,
      title: 'Реабілітація',
      description: 'Відвідування реабілітаційного центру 2 рази на тиждень. Ранкова зарядка для розминки спини',
      duration_days: 60
    }
  }
]
```
## Висновок
Після проведеня тестового запиту, я отримав відповідь, а якій можна побачити графу `treatment` одже таблиця була створена коректрна і всі інші зміни подіяли. 
Операція була проведена без помилок, з чітким відобраенням даних
### Скрипт для запиту
`test_query.js`
```java script
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log("Отримання даних з бази...\n");
    const appointments = await prisma.appointment.findMany({
        include: {
            patient: { select: { first_name: true, last_name: true } },
            doctor: { select: { first_name: true, last_name: true, is_active: true } },
            treatment: true
        }
    });

    console.dir(appointments, { depth: null });
}

main()
  .catch(e => console.error(e))
  .finally(async () => await prisma.$disconnect());
```
