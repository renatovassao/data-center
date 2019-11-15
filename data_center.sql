DROP DATABASE IF EXISTS data_center;

CREATE DATABASE data_center;

\connect data_center;

CREATE TABLE racks (
    rack_id int primary key,
    online  boolean
);

CREATE TABLE load_balancers (
    load_balancer_id    int primary key,
    rack_id             int references racks(rack_id),
    online              boolean
);

CREATE TABLE servers (
    blade_id            int primary key,
    rack_id             int references racks(rack_id),
    online              boolean
);

CREATE TABLE virtual_machines (
    virtual_machine_id  int primary key,
    blade_id            int references servers(blade_id),
    online              boolean
);

CREATE TABLE apps (
    app_id              int primary key,
    online              boolean
);

CREATE TABLE app_virtual_machines (
    app_id              int references apps(app_id),
    virtual_machine_id  int references virtual_machines(virtual_machine_id)
);

CREATE TABLE databases (
    database_id int primary key,
    master_id   int references databases(database_id),
    online      boolean
);

CREATE TABLE app_databases (
    app_id       int references apps(app_id),
    database_id  int references databases(database_id)
);

CREATE TABLE users (
    user_id  int primary key
);

CREATE TABLE user_apps (
    user_id  int references users(user_id),
    app_id   int references apps(app_id)
);

INSERT INTO racks VALUES (1, TRUE);
INSERT INTO racks VALUES (2, TRUE);
INSERT INTO racks VALUES (3, TRUE);

INSERT INTO load_balancers VALUES (1, 1, TRUE);
INSERT INTO load_balancers VALUES (2, 2, TRUE);
INSERT INTO load_balancers VALUES (3, 2, TRUE);

INSERT INTO servers VALUES (1, 1, FALSE);
INSERT INTO servers VALUES (2, 1, TRUE);
INSERT INTO servers VALUES (3, 2, TRUE);
INSERT INTO servers VALUES (4, 2, FALSE);
INSERT INTO servers VALUES (5, 3, TRUE);

INSERT INTO virtual_machines VALUES (10, 1, FALSE);
INSERT INTO virtual_machines VALUES (11, 2, TRUE);
INSERT INTO virtual_machines VALUES (20, 2, TRUE);
INSERT INTO virtual_machines VALUES (30, 2, TRUE);
INSERT INTO virtual_machines VALUES (31, 3, TRUE);
INSERT INTO virtual_machines VALUES (40, 3, TRUE);
INSERT INTO virtual_machines VALUES (41, 4, FALSE);
INSERT INTO virtual_machines VALUES (50, 4, FALSE);
INSERT INTO virtual_machines VALUES (51, 5, TRUE);
INSERT INTO virtual_machines VALUES (52, 5, TRUE);

INSERT INTO apps VALUES (1, TRUE);
INSERT INTO apps VALUES (2, TRUE);
INSERT INTO apps VALUES (3, FALSE);
INSERT INTO apps VALUES (4, FALSE);
INSERT INTO apps VALUES (5, TRUE);

INSERT INTO app_virtual_machines VALUES (1, 10);
INSERT INTO app_virtual_machines VALUES (1, 11);
INSERT INTO app_virtual_machines VALUES (2, 20);
INSERT INTO app_virtual_machines VALUES (3, 30);
INSERT INTO app_virtual_machines VALUES (3, 31);
INSERT INTO app_virtual_machines VALUES (4, 40);
INSERT INTO app_virtual_machines VALUES (4, 41);
INSERT INTO app_virtual_machines VALUES (5, 51);

INSERT INTO databases VALUES (1, NULL, TRUE);
INSERT INTO databases VALUES (2, 1, TRUE);
INSERT INTO databases VALUES (3, 1, FALSE);

INSERT INTO app_databases VALUES (1, 1);
INSERT INTO app_databases VALUES (1, 2);
INSERT INTO app_databases VALUES (2, 1);
INSERT INTO app_databases VALUES (2, 3);
INSERT INTO app_databases VALUES (3, 3);
INSERT INTO app_databases VALUES (4, 1);
INSERT INTO app_databases VALUES (4, 2);
INSERT INTO app_databases VALUES (4, 3);
INSERT INTO app_databases VALUES (5, 3);

INSERT INTO users VALUES (1);
INSERT INTO users VALUES (2);
INSERT INTO users VALUES (3);

INSERT INTO user_apps VALUES (1, 1);
INSERT INTO user_apps VALUES (1, 2);
INSERT INTO user_apps VALUES (2, 2);
INSERT INTO user_apps VALUES (3, 3);

-- Seleciona todos os apps
SELECT * FROM apps;

-- Selectiona todos os bancos de dados que estão online
SELECT * FROM databases WHERE online = TRUE;

-- Seleciona todos os bancos que não são slaves (i.e. apenas master)
SELECT * FROM databases WHERE master_id IS NULL;

-- Seleciona blade_id (renomeado como server_id) e rack_id de todos os servidores que estão em racks com id > 2
SELECT blade_id AS server_id, rack_id FROM servers WHERE rack_id > 2;

-- Seleciona os ids de todos as máquinas virtuais que estão rodando no servidor com id = 2 e estão offline
SELECT virtual_machine_id FROM virtual_machines WHERE blade_id = 2 AND online = FALSE;

-- Seleciona os ids de todos os servidores que estão em racks com (id = 2 ou id = 3) e estão online
SELECT blade_id AS id FROM servers WHERE (rack_id = 2 OR rack_id = 3) AND online = TRUE;

-- Seleciona todos as máquinas virtuais que estão rodando no servidor com id = 2 unido com as máquinas virtuais que roda o app com id = 3
CREATE TEMP TABLE virtual_machines_in_blade_2 AS SELECT virtual_machine_id FROM virtual_machines WHERE blade_id = 2;
CREATE TEMP TABLE virtual_machines_running_app_3 AS SELECT virtual_machine_id FROM app_virtual_machines WHERE app_id = 3;
SELECT virtual_machine_id FROM virtual_machines_in_blade_2 UNION SELECT virtual_machine_id FROM virtual_machines_running_app_3;

-- Seleciona todos os bds utilizadas por apps antigos (id < 3) intersectado com dbs que são escravos
CREATE TEMP TABLE databases_used_by_old_apps AS SELECT database_id FROM app_databases WHERE app_id < 3;
CREATE TEMP TABLE slave_databases AS SELECT database_id FROM databases WHERE master_id IS NOT NULL;
SELECT * FROM databases_used_by_old_apps INTERSECT SELECT * FROM slave_databases;

-- Seleciona todas as combinações de bds com apps
SELECT app_id, database_id FROM apps CROSS JOIN databases;

-- Seleciona os ids das vms e o status do servidor que a hospeda
SELECT t1.virtual_machine_id, t2.online AS server_status FROM virtual_machines t1 JOIN servers t2 ON (t1.blade_id = t2.blade_id);

-- Seleciona todos os apps com id > 3 que usam todos os bds
CREATE TEMP TABLE new_app_databases AS SELECT * FROM app_databases WHERE app_id > 3;
CREATE TEMP TABLE database_ids AS SELECT database_id FROM databases;
CREATE TEMP TABLE cross_app_databases AS SELECT * FROM (SELECT DISTINCT app_id FROM new_app_databases) AS app_ids CROSS JOIN database_ids;
CREATE TEMP TABLE not_in_all_dbs AS SELECT * FROM cross_app_databases EXCEPT SELECT * FROM new_app_databases;
SELECT app_id FROM new_app_databases EXCEPT (SELECT DISTINCT app_id FROM not_in_all_dbs);