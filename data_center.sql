CREATE TABLE racks (
    rack_id  int primary key
);

CREATE TABLE load_balancers (
    load_balancer_id    int primary key,
    rack_id             int references racks(rack_id)
);

CREATE TABLE servers (
    blade_id            int primary key,
    rack_id             int references racks(rack_id),
    virtual_machine_id  int
);

CREATE TABLE virtual_machines (
    virtual_machine_id  int primary key,
    app_instance_id     int,
    blade_id            int references servers(blade_id)
);

CREATE TABLE apps (
    app_id              int primary key,
    virtual_machine_id  int references virtual_machines(virtual_machine_id)
);

CREATE TABLE databases (
    database_id  int primary key
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

INSERT INTO racks VALUES (1);
INSERT INTO racks VALUES (2);

INSERT INTO load_balancers VALUES (1, 1);
INSERT INTO load_balancers VALUES (2, 2);

INSERT INTO servers VALUES (1, 1, 0);
INSERT INTO servers VALUES (2, 1, 0);
INSERT INTO servers VALUES (3, 2, 0);

INSERT INTO virtual_machines VALUES (10, 0, 1);
INSERT INTO virtual_machines VALUES (11, 0, 2);
INSERT INTO virtual_machines VALUES (20, 0, 2);
INSERT INTO virtual_machines VALUES (30, 0, 2);
INSERT INTO virtual_machines VALUES (31, 0, 3);

INSERT INTO apps VALUES (1, 10);
-- INSERT INTO apps VALUES (1, 11);
INSERT INTO apps VALUES (2, 20);
INSERT INTO apps VALUES (3, 30);
-- INSERT INTO apps VALUES (3, 31);

INSERT INTO databases VALUES (1);
INSERT INTO databases VALUES (2);
INSERT INTO databases VALUES (3);

INSERT INTO app_databases VALUES (1, 1);
INSERT INTO app_databases VALUES (2, 1);
INSERT INTO app_databases VALUES (3, 3);

INSERT INTO users VALUES (3);

INSERT INTO user_apps VALUES (3, 3);