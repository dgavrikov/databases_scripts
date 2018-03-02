--Вот такие функции нужно создать, чтобы pgadmin3 смог спокойно соединиться к PostgreSQL 10:

create function pg_last_xlog_receive_location() returns text as $$ select pg_last_wal_receive_lsn()::text $$ language sql;

create function pg_last_xlog_replay_location() returns text as $$ select pg_last_wal_replay_lsn()::text $$ language sql;

create function pg_is_xlog_replay_paused() returns bool as $$ select pg_is_wal_replay_paused() $$ language sql;