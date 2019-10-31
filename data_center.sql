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