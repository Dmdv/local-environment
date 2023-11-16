CREATE USER dev;

CREATE DATABASE parking_lot_api_development;
CREATE DATABASE parking_lot_api_production;
CREATE DATABASE parking_lot_api_test;

GRANT ALL PRIVILEGES ON DATABASE parking_lot_api_development TO dev;
GRANT ALL PRIVILEGES ON DATABASE parking_lot_api_production TO dev;
GRANT ALL PRIVILEGES ON DATABASE parking_lot_api_test TO dev;

