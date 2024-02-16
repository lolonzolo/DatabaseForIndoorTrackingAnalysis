BEGIN;



/******************************************************************************* PUBLIC SCHEMA *******************************************************************************/



DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;


COMMENT ON SCHEMA public is 'This is the main schema of the database, that is populated with the final, correct data.';


CREATE SEQUENCE indoor_seq START 1;


CREATE TABLE IF NOT EXISTS public.data_source
(
    id integer NOT NULL DEFAULT nextval('indoor_seq'),
    name character varying NOT NULL UNIQUE,
    notes character varying,
    url character varying,
    PRIMARY KEY (id)
);


COMMENT ON TABLE public.data_source IS 'Table used for data lineage purposes. Attribute ''name'' holds the unique name of the data source.';


CREATE TABLE IF NOT EXISTS public.user
(
    id integer NOT NULL DEFAULT nextval('indoor_seq'),
    username character varying,
    code character varying NOT NULL,
    type_id integer NOT NULL,
    notes character varying,
    data_source_id integer NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT user_uc UNIQUE (code, data_source_id),
    CONSTRAINT user_uc2 UNIQUE (username, data_source_id)
);

COMMENT ON TABLE public.user
    IS 'The users that collect the fingerprints. Type_id can be used to distinguish, for instance, between offline (trusted) and online users.';


CREATE TABLE IF NOT EXISTS public.user_type
(
    id integer DEFAULT nextval('indoor_seq'),
    description character varying NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT user_type_uc UNIQUE (description)
);


COMMENT ON TABLE public.user_type
    IS 'The table collects the possible user types, for instance, offline (trusted) and online users.';



CREATE DOMAIN fingerprint_purpose AS TEXT
CHECK(
   VALUE = 'training'
OR VALUE = 'validation'
OR VALUE = 'test'
);

CREATE TABLE IF NOT EXISTS public.fingerprint
(
    id integer DEFAULT nextval('indoor_seq'),
    code integer NOT NULL,
    data_source_id integer NOT NULL,
    timestamp timestamp without time zone,
    coordinate_x numeric,
    coordinate_y numeric,
    coordinate_z numeric,
    preceded_by_fingerprint_id integer,
    followed_by_fingerprint_id integer,
    user_id integer,
    device_id integer,
    is_radio_map boolean NOT NULL,
    acquired_at_tile_place_id integer,
    ml_purpose fingerprint_purpose,
    notes character varying,
    PRIMARY KEY (id),
    CONSTRAINT fingerprint_uc UNIQUE (code, data_source_id)
);

COMMENT ON TABLE public.fingerprint
    IS 'Parent table of the fingerprint hierarchy, which has a partial specialization into radio map fingerprint (attribute is_radio_map). It is a weak entity with respect to the data source. Code is the partial identifier, and it represents, for instance, the row number in the original file. This is enforced by a unique constraint placed over (code, data_source_id), while fingerprint still has a surrogate key, named id. The timestamp is without timezone, so it is assumed that the original data is already converted to consider UTC time zone. Coordinate attributes pertain only to radio map fingerprints, as well as attribute acquired_at_tile_place_id. Attribute ml_purpose allows to keep track of the intended usage of the fingeprint in the original dataset, if any, among training, validation, test purposes.';




CREATE TABLE IF NOT EXISTS public.observation_cellular
(
    fingerprint_id integer,
    is_valid boolean,
    PRIMARY KEY (fingerprint_id)
);

COMMENT ON TABLE public.observation_cellular
    IS 'Cellular data pertaining to the fingerprint, sensed around the environment.';




CREATE TABLE IF NOT EXISTS public.observation_wifi
(
    fingerprint_id integer,
    is_valid boolean,
    PRIMARY KEY (fingerprint_id)
);

COMMENT ON TABLE public.observation_wifi
    IS 'WiFi data pertaining to the fingerprint, sensed around the environment.';




CREATE TABLE IF NOT EXISTS public.observation_gnss
(
    fingerprint_id integer,
    is_valid boolean,
    latitude numeric,
    longitude numeric,
    elevation numeric,
    num_satellites integer,
    PRIMARY KEY (fingerprint_id)
);

COMMENT ON TABLE public.observation_gnss
    IS 'GNSS data pertaining to the fingerprint, sensed around the environment.';



CREATE TABLE IF NOT EXISTS public.observation_imu
(
    fingerprint_id integer,
    is_valid boolean,
    PRIMARY KEY (fingerprint_id)
);

COMMENT ON TABLE public.observation_imu
    IS 'IMU data pertaining to the fingerprint, sensed around the environment. In principle, an IMU observation contains differntial data with respect to a previous fingerprint.';




CREATE TABLE IF NOT EXISTS public.observation_imu_accelerometer
(
    fingerprint_id integer,
    epoch integer,
    axis_x numeric not null,
    axis_y numeric not null,
    axis_z numeric not null,
    PRIMARY KEY (fingerprint_id, epoch)
);

COMMENT ON TABLE public.observation_imu_accelerometer
    IS 'Accelerometer data pertaining to an IMU observation. In principle, an IMU observation may have several of these data, that can be discerned, among the same observation, by means of the attribute epoch. Being epoch of domain integer, this means that it can be used as a kind of timestamp, as well as a simple incremental value that orders the data within an obsvervation.';




CREATE TABLE IF NOT EXISTS public.observation_imu_gyroscope
(
    fingerprint_id integer,
    epoch integer,
    axis_x numeric not null,
    axis_y numeric not null,
    axis_z numeric not null,
    PRIMARY KEY (fingerprint_id, epoch)
);

COMMENT ON TABLE public.observation_imu_gyroscope
    IS 'Gyroscope data pertaining to an IMU observation. In principle, an IMU observation may have several of these data, that can be discerned, among the same observation, by means of the attribute epoch. Being epoch of domain integer, this means that it can be used as a kind of timestamp, as well as a simple incremental value that orders the data within an obsvervation.';



CREATE TABLE IF NOT EXISTS public.observation_imu_magnetometer
(
    fingerprint_id integer,
    epoch integer,
    axis_x numeric not null,
    axis_y numeric not null,
    axis_z numeric not null,
    PRIMARY KEY (fingerprint_id, epoch)
);

COMMENT ON TABLE public.observation_imu_magnetometer
    IS 'Magnetometer data pertaining to an IMU observation. In principle, an IMU observation may have several of these data, that can be discerned, among the same observation, by means of the attribute epoch. Being epoch of domain integer, this means that it can be used as a kind of timestamp, as well as a simple incremental value that orders the data within an obsvervation.';



CREATE TABLE IF NOT EXISTS public.observation_bluetooth
(
    fingerprint_id integer,
    is_valid boolean,
    PRIMARY KEY (fingerprint_id)
);

COMMENT ON TABLE public.observation_bluetooth
    IS 'Bluetooth data pertaining to the fingerprint, sensed around the environment.';



CREATE TABLE IF NOT EXISTS public.cell
(
    id integer DEFAULT nextval('indoor_seq'),
    ci integer NOT NULL,
    lac integer NOT NULL,
    mnc integer NOT NULL,
    mcc integer NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT cell_uc UNIQUE (ci, lac, mnc, mcc) 
);

COMMENT ON TABLE public.cell
    IS 'A mobile network cell that can be sensed in the environment.';



CREATE TABLE IF NOT EXISTS public.ap
(
    id integer DEFAULT nextval('indoor_seq'),
    code character varying NOT NULL,
    mac character varying,
    PRIMARY KEY (id),
    CONSTRAINT ap_uc UNIQUE (mac)
);

COMMENT ON TABLE public.ap
    IS 'A WiFi access point that can be sensed around the environment.';



CREATE TABLE IF NOT EXISTS public.cell_detection
(
    cell_id integer,
    observation_cellular_fingerprint_id integer,
    rss numeric NOT NULL,
    PRIMARY KEY (cell_id, observation_cellular_fingerprint_id)
);


ALTER TABLE public.cell_detection 
ADD CONSTRAINT cell_detection_rss 
CHECK (rss <= 0);


COMMENT ON TABLE public.cell_detection
    IS 'A mobile network cell that has been sensed in the environment with a signal intensity recorded by attribute rss. Rss has a value <= 0, and it is considered to be expressed in dbm.';




CREATE TABLE IF NOT EXISTS public.ap_detection
(
    ap_id integer,
    observation_wifi_fingerprint_id integer,
    rss numeric NOT NULL,
    PRIMARY KEY (ap_id, observation_wifi_fingerprint_id)
);


ALTER TABLE public.ap_detection 
ADD CONSTRAINT ap_detection_rss 
CHECK (rss <= 0);


COMMENT ON TABLE public.ap_detection
    IS 'An access point that has been sensed in the environment with a signal intensity recorded by attribute rss. Rss has a value <= 0, and it is considered to be expressed in dbm.';





CREATE TABLE IF NOT EXISTS public.bluetooth_device
(
    id integer DEFAULT nextval('indoor_seq'),
    name character varying NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON TABLE public.bluetooth_device
    IS 'A Bluetooth device that can be sensed around the environment.';



CREATE TABLE IF NOT EXISTS public.bluetooth_detection
(
    bluetooth_device_id integer,
    observation_bluetooth_fingerprint_id integer,
    rss numeric NOT NULL,
    PRIMARY KEY (bluetooth_device_id, observation_bluetooth_fingerprint_id)
);


ALTER TABLE public.bluetooth_detection 
ADD CONSTRAINT bluetooth_detection_rss 
CHECK (rss <= 0);


COMMENT ON TABLE public.bluetooth_detection
    IS 'A Bluetooth device that has been sensed in the environment with a signal intensity recorded by attribute rss. Rss has a value <= 0, and it is considered to be expressed in dbm.';



CREATE TABLE IF NOT EXISTS public.cell_data_source
(
    cell_id integer,
    data_source_id integer,
    PRIMARY KEY (cell_id, data_source_id)
);

COMMENT ON TABLE public.cell_data_source
    IS 'Provides data lineage information to table cell.';



CREATE TABLE IF NOT EXISTS public.ap_data_source
(
    ap_id integer,
    data_source_id integer,
    PRIMARY KEY (ap_id, data_source_id)
);

COMMENT ON TABLE public.ap_data_source
    IS 'Provides data lineage information to table ap.';



CREATE TABLE IF NOT EXISTS public.bluetooth_device_data_source
(
    bluetooth_device_id integer,
    data_source_id integer,
    PRIMARY KEY (bluetooth_device_id, data_source_id)
);

COMMENT ON TABLE public.bluetooth_device_data_source
    IS 'Provides data lineage information to table bluetooth device.';




CREATE TABLE IF NOT EXISTS public.place
(
    id integer DEFAULT nextval('indoor_seq'),
    name character varying NOT NULL,
    description character varying, 
    PRIMARY KEY (id)
);

COMMENT ON TABLE public.place
    IS 'The parent entity of the place hierarchy';




CREATE TABLE IF NOT EXISTS public.place_data_source
(
    data_source_id integer,
    place_id integer,
    PRIMARY KEY (data_source_id, place_id)
);

COMMENT ON TABLE public.place_data_source
    IS 'Provides data lineage information to table place.';




CREATE TABLE IF NOT EXISTS public.contains
(
    container_place_id integer,
    contained_place_id integer,
    PRIMARY KEY (container_place_id, contained_place_id)
);

COMMENT ON TABLE public.contains
    IS 'It models containment relationships among places. A building may conitain several floors, and a floor may contain several sites or tiles directly.';




CREATE TABLE IF NOT EXISTS public.building
(
    place_id integer,
    area numeric,
    PRIMARY KEY (place_id)
);

COMMENT ON TABLE public.building
    IS 'A building is considered to be a structurally independent element in the indoor positionin domain, possibly connected to other elements by means, for instance, of a bridge.';


CREATE TABLE IF NOT EXISTS public.adjacent_to_building
(
    building_1_place_id integer,
    building_2_place_id integer,
    PRIMARY KEY (building_2_place_id, building_1_place_id)
);

COMMENT ON TABLE public.adjacent_to_building
    IS 'To be used for instance if two buildings have a wall in common.';


CREATE TABLE IF NOT EXISTS public.floor
(
    place_id integer,
    area numeric,
    height numeric,
    above_of_floor_place_id integer,
    below_of_floor_place_id integer,
    PRIMARY KEY (place_id)
);

COMMENT ON TABLE public.floor
    IS 'Information regarding all floors of a building should be stored in the database, even if they are not used for positioning purposes.';



CREATE TABLE IF NOT EXISTS public.site
(
    place_id integer,
    area numeric,
    height numeric,
    PRIMARY KEY (place_id)
);

COMMENT ON TABLE public.site
    IS 'A generic spatially restriced area in the indoor domain, for instance, a room or a corridor.';




CREATE DOMAIN tile_type AS TEXT
CHECK(
   VALUE = 'grid'
OR VALUE = 'zone'
OR VALUE = 'logical'
OR VALUE = 'crowd'
);


CREATE TABLE IF NOT EXISTS public.tile
(
    place_id integer,
    coordinate_a_x numeric,
    coordinate_a_y numeric,
    coordinate_b_x numeric,
    coordinate_b_y numeric,
    coordinate_c_x numeric,
    coordinate_c_y numeric,
    coordinate_d_x numeric,
    coordinate_d_y numeric,
    type tile_type NOT NULL,
    tessellation_id integer NOT NULL,
    PRIMARY KEY (place_id)
);


COMMENT ON TABLE public.tile
    IS 'For logical tiles, just coordinate_a_x and coordinate_a_y are to be possibly used. Crowd tiles do not have coordinate information. Finally, grid and zone tiles should have all four pair of coordinates.';


CREATE TABLE IF NOT EXISTS public.adjacent_to_tile
(
    tile_1_place_id integer,
    tile_2_place_id integer,
    walkable boolean,
    cost numeric,
    PRIMARY KEY (tile_2_place_id, tile_1_place_id),
    CONSTRAINT chk_adj CHECK (cost >= 0)
);

COMMENT ON TABLE public.adjacent_to_tile
    IS 'To be used for instance if two tiles are adjacent to one another. Walkable means that a user can physically move from one tile to the other, and cost represents the traversing cost, for instance, in terms of expected time.';



CREATE TABLE IF NOT EXISTS public.estimation
(
    id integer primary key,
    fingerprint_id integer,
    timestamp timestamp,
    notes varchar, 
    coordinate_x numeric,
    coordinate_y numeric,
    coordinate_z numeric,
    CONSTRAINT u_estimation UNIQUE(fingerprint_id, timestamp)
);


COMMENT ON TABLE public.estimation
    IS 'It is an estimation related to a fingerprint. In general, a fingerprint may have more than one estimation.';




CREATE TABLE IF NOT EXISTS public.predicted_at
(
    estimation_id integer,
    place_id integer,
    confidence numeric,
    PRIMARY KEY (estimation_id, place_id)
);

COMMENT ON TABLE public.predicted_at
    IS 'It links a fingerprint estimation with one or more places. Confidence can be, for instance, the prediction probability.';



CREATE TABLE IF NOT EXISTS public.device
(
    id integer DEFAULT nextval('indoor_seq'),
    code character varying NOT NULL,
    data_source_id integer NOT NULL,
    device_model_id integer,
    notes character varying,
    PRIMARY KEY (id),
    CONSTRAINT device_uc UNIQUE (code, data_source_id)
);

COMMENT ON TABLE public.device
    IS 'A physical device that senses a fingerprint.';



CREATE TABLE IF NOT EXISTS public.device_model
(
    manufacturer character varying NOT NULL,
    name character varying NOT NULL,
    type_id integer NOT NULL,
    id integer DEFAULT nextval('indoor_seq'),
    PRIMARY KEY (id),
    CONSTRAINT device_model_uc UNIQUE (manufacturer, name)
);


CREATE TABLE IF NOT EXISTS public.device_model_type
(
    id integer DEFAULT nextval('indoor_seq'),
    description character varying NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT device_mode_type_uc UNIQUE (description)
);




CREATE TABLE IF NOT EXISTS public.tessellation
(
    id integer DEFAULT nextval('indoor_seq'),
    floor_place_id integer not null,
    data_source_id integer not null, 
    type tile_type NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT tessellation_uc UNIQUE (floor_place_id, data_source_id, type)
);

COMMENT ON TABLE public.tessellation
    IS 'It defines a strategy for the collection of fingerprints, and it acts as a container for tiles of its same type. Given a floor and a data source, there can be at most one tessellation of each kind. So, for instance, within the same dataset, a floor can have both a tessellation of type zone and grid, but not two different tessellations of type logical.';





ALTER TABLE public.data_source DROP CONSTRAINT data_source_pkey;
ALTER TABLE public.user DROP CONSTRAINT user_pkey;
ALTER TABLE public.user_type DROP CONSTRAINT user_type_pkey;
ALTER TABLE public.fingerprint DROP CONSTRAINT fingerprint_pkey;
ALTER TABLE public.observation_cellular DROP CONSTRAINT observation_cellular_pkey;
ALTER TABLE public.observation_wifi DROP CONSTRAINT observation_wifi_pkey;
ALTER TABLE public.observation_gnss DROP CONSTRAINT observation_gnss_pkey;
ALTER TABLE public.observation_imu DROP CONSTRAINT observation_imu_pkey;
ALTER TABLE public.observation_imu_accelerometer DROP CONSTRAINT observation_imu_accelerometer_pkey;
ALTER TABLE public.observation_imu_gyroscope DROP CONSTRAINT observation_imu_gyroscope_pkey;
ALTER TABLE public.observation_imu_magnetometer DROP CONSTRAINT observation_imu_magnetometer_pkey;
ALTER TABLE public.observation_bluetooth DROP CONSTRAINT observation_bluetooth_pkey;
ALTER TABLE public.cell DROP CONSTRAINT cell_pkey;
ALTER TABLE public.ap DROP CONSTRAINT ap_pkey;
ALTER TABLE public.cell_detection DROP CONSTRAINT cell_detection_pkey;
ALTER TABLE public.ap_detection DROP CONSTRAINT ap_detection_pkey;
ALTER TABLE public.bluetooth_device DROP CONSTRAINT bluetooth_device_pkey;
ALTER TABLE public.bluetooth_detection DROP CONSTRAINT bluetooth_detection_pkey;
ALTER TABLE public.cell_data_source DROP CONSTRAINT cell_data_source_pkey;
ALTER TABLE public.ap_data_source DROP CONSTRAINT ap_data_source_pkey;
ALTER TABLE public.bluetooth_device_data_source DROP CONSTRAINT bluetooth_device_data_source_pkey;
ALTER TABLE public.place DROP CONSTRAINT place_pkey;
ALTER TABLE public.place_data_source DROP CONSTRAINT place_data_source_pkey;
ALTER TABLE public.contains DROP CONSTRAINT contains_pkey;
ALTER TABLE public.building DROP CONSTRAINT building_pkey;
ALTER TABLE public.adjacent_to_building DROP CONSTRAINT adjacent_to_building_pkey;
ALTER TABLE public.floor DROP CONSTRAINT floor_pkey;
ALTER TABLE public.site DROP CONSTRAINT site_pkey;
ALTER TABLE public.tile DROP CONSTRAINT tile_pkey;
ALTER TABLE public.adjacent_to_tile DROP CONSTRAINT adjacent_to_tile_pkey;
ALTER TABLE public.estimation DROP CONSTRAINT estimation_pkey;
ALTER TABLE public.predicted_at DROP CONSTRAINT predicted_at_pkey;
ALTER TABLE public.device DROP CONSTRAINT device_pkey;
ALTER TABLE public.device_model DROP CONSTRAINT device_model_pkey;
ALTER TABLE public.device_model_type DROP CONSTRAINT device_model_type_pkey;
ALTER TABLE public.tessellation DROP CONSTRAINT tessellation_pkey;
ALTER TABLE public.data_source DROP CONSTRAINT data_source_name_key;
ALTER TABLE public.user DROP CONSTRAINT user_uc2;
ALTER TABLE public.user DROP CONSTRAINT user_uc;
ALTER TABLE public.user_type DROP CONSTRAINT user_type_uc;
ALTER TABLE public.fingerprint DROP CONSTRAINT fingerprint_uc;
ALTER TABLE public.cell DROP CONSTRAINT cell_uc;
ALTER TABLE public.ap DROP CONSTRAINT ap_uc;
ALTER TABLE public.estimation DROP CONSTRAINT u_estimation;
ALTER TABLE public.device DROP CONSTRAINT device_uc;
ALTER TABLE public.device_model DROP CONSTRAINT device_model_uc;
ALTER TABLE public.device_model_type DROP CONSTRAINT device_mode_type_uc;
ALTER TABLE public.tessellation DROP CONSTRAINT tessellation_uc;



END;









