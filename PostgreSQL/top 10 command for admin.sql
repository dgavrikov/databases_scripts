1. Как найти самую большую таблицу в базе данных PostgreSQL?

# SELECT 
    relname AS "table_name", 
    relpages AS "size_in_pages" 
FROM 
    pg_class 
ORDER BY 
    relpages DESC 
LIMIT 
    1;

Результатом будет самая большая таблица (в примере testtable1) в страницах. Размер одной страницы равен 8KB (т.е. размер таблицы в примере — 2,3GB)

   TABLE_NAME   | size_in_pages 
----------------+---------------
 testtable1     |        299211

 
2. Как узнать размер всей базы данных PostgreSQL?

# SELECT pg_database_size( 'sampledb' );

Результатом будет размер базы данных в байтах:

 pg_database_size 
------------------
      27641546936

Если вы хотите получить размер в более читаемом («человеческом») формате — «оберните» результат в функцию pg_size_pretty():

# SELECT pg_size_pretty( pg_database_size( 'sampledb' ) );

Результат:

 pg_size_pretty 
----------------
 26 GB

 
3. Как узнать размер таблицы в базе данных PostgreSQL?

# SELECT pg_size_pretty( pg_total_relation_size( 'testtable1' ) );

Результатом будет размер таблицы testtable1, включая индексы. Результат будет отображен сразу в удобном для чтения формате, а не в байтах.

 pg_size_pretty 
----------------
 4872 MB

Если вам нужно узнать размер таблицы без индексов, тогда следует выполнить такой запрос:

# SELECT pg_size_pretty( pg_relation_size( 'testtable1' ) );

Результат:

 pg_size_pretty 
----------------
 2338 MB

 
4. Как узнать текущую версию сервера PostgreSQL?

# SELECT version();

Результат будет подобным этому:

                                           version                                            
----------------------------------------------------------------------------------------------
 PostgreSQL 9.3.1 on x86_64-unknown-linux-gnu, compiled by gcc (Debian 4.7.2-5) 4.7.2, 64-bit

 
5. Как выполнить SQL-файл в PostgreSQL?

Для данной цели существует специальная команда в консольной утилите:

# \i /path/to/file.sql

Где /path/to/file.sql — это путь к вашему SQL-файлу. Обратите внимание, что он должен лежать в доступной для чтения пользователя postgres директории.

 
6. Как отобразить список всех баз данных сервера PostgreSQL?

Для данной цели существует специальная команда в консольной утилите:

# \l

Результат:

                                           List of databases
    Name     |   Owner    | Encoding  |   Collate   |    Ctype    |     Access privileges     
-------------+------------+-----------+-------------+-------------+---------------------------
 sampledb    | sampleuser | UTF8      | uk_UA.UTF-8 | uk_UA.UTF-8 | =Tc/sampleuser
             |            |           |             |             | sampleuser=CTc/sampleuser
 postgres    | postgres   | UTF8      | uk_UA.UTF-8 | uk_UA.UTF-8 | 
 template0   | postgres   | UTF8      | uk_UA.UTF-8 | uk_UA.UTF-8 | =c/postgres
             |            |           |             |             | postgres=CTc/postgres
 template1   | postgres   | UTF8      | uk_UA.UTF-8 | uk_UA.UTF-8 | postgres=CTc/postgres
             |            |           |             |             | pgsql=CTc/postgres
             |            |           |             |             | =c/postgres

 
7. Как отобразить список всех таблиц в базе данных PostgreSQL?

Для данной цели существует специальная команда в консольной утилите что покажет список таблиц в текущей БД.

# \dt

Результат:

                    List of relations
 Schema |              Name             | Type  | Owner  
--------+-------------------------------+-------+--------
 public | testtable1                    | table | sampleuser
 public | testtable2                    | table | sampleuser
 public | testtable3                    | table | sampleuser
 public | testtable4                    | table | sampleuser
 ...

 
8. Как показать структуру, индексы и прочие элементы выбранной таблицы в PostgreSQL?

Для данной цели существует специальная команда в консольной утилите:

# \d testtable1

Где testtable1 — имя таблицы

Результат:

               Table "public.testtable1"
    Column    |          Type          | Modifiers 
--------------+------------------------+-----------
 begin_ip     | ip4                    | not null
 end_ip       | ip4                    | not null
 begin_num    | bigint                 | not null
 end_num      | bigint                 | not null
 country_code | character(2)           | not null
 country_name | character varying(255) | not null
 ip_range     | ip4r                   | 
Indexes:
    "testtable1_iprange_index" gist (ip_range) WITH (fillfactor=100)

 
9. Как отобразить время выполнения запроса в консольной утилите PostgreSQL?

# \timing

После чего все запросы станут отображаться в консольной утилите со временем выполнения.
Отключаются эти уведомления точно так же, как и включаются — вызовом:

# \timing

 
10. Как отобразить все команды консольной утилиты PostgreSQL?

# \?

Это наверное самый важный пункт, т.к. любой DBA должен знать как вызвать эту справку :-)

Это всё.
Удачи.
