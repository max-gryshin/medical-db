CREATE TYPE sex AS ENUM ('мужской', 'женский');
CREATE TYPE patient_status AS ENUM ('легкое', 'нормальное', 'критическое');
CREATE TYPE hospitalization_type AS ENUM ('по направлению', 'скорая помощь', 'самостоятельно', 'перевод', 'плановая');
CREATE TYPE diagnosis_status AS ENUM ('предположительный', 'подтвержденный', 'не подтвержденный');
CREATE TYPE service AS ENUM ('vip', 'обычный', 'индивидуальный', 'комфортный');
CREATE TYPE ward_type AS ENUM ('мужская', 'женская', 'смешанная');
CREATE TYPE medical_qualification AS ENUM ('мед. сестра', 'младший персонал', 'средний персонал', 'старший персонал');
CREATE TYPE medical_specialization AS ENUM ('инфекционист', 'эпидемиолог', 'реаниматолог', 'хирург', 'дерматовенеролог');
CREATE TYPE medical_profile AS ENUM ('нейроинфекции', 'воздушно-капельные инфекции', 'гепатит', 'ВИЧ-инфекции', 'оппортунистические инфекции', 'кожные и венерические инфекции');

create table if not exists patient
(
    id            serial
        constraint patient_pk
            primary key,
    first_name    varchar(32)                         not null,
    last_name     varchar(32)                         not null,
    middle_name   varchar(32)                         not null,
    dob           date                                not null,
    sex           sex                                 not null,
    has_insurance boolean   default false             not null,
    status        patient_status                      not null,
    created_at    timestamp default CURRENT_TIMESTAMP not null,
    updated_at    timestamp default CURRENT_TIMESTAMP not null
);

alter table patient
    owner to postgres;

--create unique index if not exists patient_first_name_last_name_middle_name_uindex
  --  on patient (first_name, last_name, middle_name);

create table if not exists contact
(
    id          serial
        constraint contact_pk
            primary key,
    first_name  varchar(32)                         not null,
    last_name   varchar(32)                         not null,
    middle_name varchar(32)                         not null,
    dob         date                                not null,
    sex         sex                                 not null,
    level       integer                             not null,
    status      patient_status                      not null,
    created_at  timestamp default CURRENT_TIMESTAMP not null,
    updated_at  timestamp default CURRENT_TIMESTAMP not null,
    patient_id  integer
        constraint contact_patient_id_fk
            references patient
            on delete cascade
);

alter table contact
    owner to postgres;

create table if not exists address
(
    id         serial
        constraint address_pk
            primary key,
    city       varchar(32),
    street     varchar(256),
    house      varchar(128),
    created_at timestamp default CURRENT_TIMESTAMP not null,
    updated_at timestamp default CURRENT_TIMESTAMP not null,
    patient_id integer
        constraint address_patient_id_fk
            references patient
            on delete cascade
);

alter table address
    owner to postgres;

create table if not exists hospitalization
(
    id         serial
        constraint hospitalization_pk
            primary key,
    type       hospitalization_type,
    start_at   timestamp default CURRENT_TIMESTAMP not null,
    end_at     timestamp default null,
    created_at timestamp default CURRENT_TIMESTAMP not null,
    updated_at timestamp default CURRENT_TIMESTAMP not null,
    patient_id integer
        constraint hospitalization_patient_id_fk
            references patient
            on delete cascade
);

create index hospitalization_id_index
    on hospitalization (id);

create index hospitalization_patient_index
    on hospitalization (patient_id);

create index hospitalization_date_index
    on hospitalization (start_at, end_at);

alter table hospitalization
    owner to postgres;

create table if not exists department
(
    id           serial
        constraint department_pk
            primary key,
    name         varchar(128)                        not null,
    created_at   timestamp default CURRENT_TIMESTAMP not null,
    updated_at   timestamp default CURRENT_TIMESTAMP not null
);

alter table department
    owner to postgres;

create table if not exists ward
(
    id            serial
        constraint ward_pk
            primary key,
    number        varchar(32),
    capacity      bigint,
    service       service,
    type          ward_type,
    created_at    timestamp default CURRENT_TIMESTAMP not null,
    updated_at    timestamp default CURRENT_TIMESTAMP not null,
    department_id integer
        constraint ward_department_id_fk_1
            references department
);

alter table ward
    owner to postgres;

create table if not exists diagnosis
(
    id                 serial
    constraint diagnosis_pk
    primary key,
    status             diagnosis_status,
    created_at         timestamp default CURRENT_TIMESTAMP not null,
    updated_at         timestamp default CURRENT_TIMESTAMP not null,
    parent             integer,
    hospitalization_id integer
        constraint diagnosis_hospitalization_id_fk
        references hospitalization,
    ward_id integer
        constraint diagnosis_ward_id_fk
        references ward
);

create index diagnosis_ward_index
    on diagnosis (ward_id);

alter table diagnosis
    owner to postgres;

create table if not exists medical_staff
(
    id             serial
    constraint medical_staff_pk
    primary key,
    first_name     varchar(32)                         not null,
    last_name      varchar(32)                         not null,
    middle_name    varchar(32)                         not null,
    dob            date                                not null,
    carier_start   date default null,
    sex            sex                                 not null,
    qualification  medical_qualification default null,
    patient_limit  integer,
    specialization medical_specialization              not null,
    profile        medical_profile                     not null,
    created_at     timestamp default CURRENT_TIMESTAMP not null,
    updated_at     timestamp default CURRENT_TIMESTAMP not null,
    department_id  integer
        constraint medical_staff_department_id_fk
            references department
    );

create index medical_staff_patient_limit_index
    on medical_staff (patient_limit);

alter table medical_staff
    owner to postgres;

create table if not exists disinfection_schedule
(
    id           serial
        constraint disinfection_schedule_pk
            primary key,
    date         timestamp default CURRENT_TIMESTAMP not null,
    duration     daterange,
    disinfectant varchar(256),
    created_at   timestamp default CURRENT_TIMESTAMP not null,
    updated_at   timestamp default CURRENT_TIMESTAMP not null,
    ward_id      integer
        constraint disinfection_schedule_ward_id_fk
            references ward
);

alter table disinfection_schedule
    owner to postgres;

