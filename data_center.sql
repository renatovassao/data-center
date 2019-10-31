CREATE TABLE databases (
    database_id  int
);

CREATE TABLE app_databases (
    app_id       int,
    database_id  int
);

CREATE TABLE apps (
    app_id              int,
    virtual_machine_id  int
);

CREATE TABLE user_apps (
    user_id  int,
    app_id   int
);

CREATE TABLE users (
    user_id  int
);

CREATE TABLE virtual_machine (
    virtual_machine_id  int,
    app_instance_id     int,
    blade_id            int
);

CREATE TABLE servers (
    blade_id            int,
    rack_id             int,
    virtual_machine_id  int
);

CREATE TABLE racks (
    rack_id  int
);

CREATE TABLE load_balancers (
    load_balancer_id    int,
    rack_id             int
);