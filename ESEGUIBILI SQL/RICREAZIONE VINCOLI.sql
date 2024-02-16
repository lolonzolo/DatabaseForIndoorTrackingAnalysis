/* Here, foreign key constraints are added to the previous tables*/


ALTER TABLE public.adjacent_to_building ADD CONSTRAINT adjacent_to_building_pkey PRIMARY KEY (building_1_place_id, building_2_place_id);
ALTER TABLE public.adjacent_to_tile ADD CONSTRAINT adjacent_to_tile_pkey PRIMARY KEY (tile_1_place_id, tile_2_place_id);
ALTER TABLE public.ap ADD CONSTRAINT ap_pkey PRIMARY KEY (id);
ALTER TABLE public.ap_data_source ADD CONSTRAINT ap_data_source_pkey PRIMARY KEY (ap_id, data_source_id);
ALTER TABLE public.ap_detection ADD CONSTRAINT ap_detection_pkey PRIMARY KEY (ap_id, observation_wifi_fingerprint_id);
ALTER TABLE public.bluetooth_detection ADD CONSTRAINT bluetooth_detection_pkey PRIMARY KEY (bluetooth_device_id, observation_bluetooth_fingerprint_id);
ALTER TABLE public.bluetooth_device ADD CONSTRAINT bluetooth_device_pkey PRIMARY KEY (id);
ALTER TABLE public.bluetooth_device_data_source ADD CONSTRAINT bluetooth_device_data_source_pkey PRIMARY KEY (data_source_id, bluetooth_device_id);
ALTER TABLE public.building ADD CONSTRAINT building_pkey PRIMARY KEY (place_id);
ALTER TABLE public.cell ADD CONSTRAINT cell_pkey PRIMARY KEY (id);
ALTER TABLE public.cell_data_source ADD CONSTRAINT cell_data_source_pkey PRIMARY KEY (data_source_id, cell_id);
ALTER TABLE public.cell_detection ADD CONSTRAINT cell_detection_pkey PRIMARY KEY (observation_cellular_fingerprint_id, cell_id);
ALTER TABLE public.contains ADD CONSTRAINT contains_pkey PRIMARY KEY (contained_place_id, container_place_id);
ALTER TABLE public.data_source ADD CONSTRAINT data_source_pkey PRIMARY KEY (id);
ALTER TABLE public.device ADD CONSTRAINT device_pkey PRIMARY KEY (id);
ALTER TABLE public.device_model ADD CONSTRAINT device_model_pkey PRIMARY KEY (id);
ALTER TABLE public.device_model_type ADD CONSTRAINT device_model_type_pkey PRIMARY KEY (id);
ALTER TABLE public.estimation ADD CONSTRAINT estimation_pkey PRIMARY KEY (id);
ALTER TABLE public.fingerprint ADD CONSTRAINT fingerprint_pkey PRIMARY KEY (id);
ALTER TABLE public.floor ADD CONSTRAINT floor_pkey PRIMARY KEY (place_id);
ALTER TABLE public.observation_bluetooth ADD CONSTRAINT observation_bluetooth_pkey PRIMARY KEY (fingerprint_id);
ALTER TABLE public.observation_cellular ADD CONSTRAINT observation_cellular_pkey PRIMARY KEY (fingerprint_id);
ALTER TABLE public.observation_gnss ADD CONSTRAINT observation_gnss_pkey PRIMARY KEY (fingerprint_id);
ALTER TABLE public.observation_imu ADD CONSTRAINT observation_imu_pkey PRIMARY KEY (fingerprint_id);
ALTER TABLE public.observation_imu_accelerometer ADD CONSTRAINT observation_imu_accelerometer_pkey PRIMARY KEY (epoch, fingerprint_id);
ALTER TABLE public.observation_imu_gyroscope ADD CONSTRAINT observation_imu_gyroscope_pkey PRIMARY KEY (epoch, fingerprint_id);
ALTER TABLE public.observation_imu_magnetometer ADD CONSTRAINT observation_imu_magnetometer_pkey PRIMARY KEY (epoch, fingerprint_id);
ALTER TABLE public.observation_wifi ADD CONSTRAINT observation_wifi_pkey PRIMARY KEY (fingerprint_id);
ALTER TABLE public.place ADD CONSTRAINT place_pkey PRIMARY KEY (id);
ALTER TABLE public.place_data_source ADD CONSTRAINT place_data_source_pkey PRIMARY KEY (place_id, data_source_id);
ALTER TABLE public.predicted_at ADD CONSTRAINT predicted_at_pkey PRIMARY KEY (estimation_id, place_id);
ALTER TABLE public.site ADD CONSTRAINT site_pkey PRIMARY KEY (place_id);
ALTER TABLE public.tessellation ADD CONSTRAINT tessellation_pkey PRIMARY KEY (id);
ALTER TABLE public.tile ADD CONSTRAINT tile_pkey PRIMARY KEY (place_id);
ALTER TABLE public.user ADD CONSTRAINT user_pkey PRIMARY KEY (id);


ALTER TABLE public.ap ADD CONSTRAINT ap_uc UNIQUE (mac);
ALTER TABLE public.cell ADD CONSTRAINT cell_uc UNIQUE (ci, mcc, mnc, lac);
ALTER TABLE public.data_source ADD CONSTRAINT data_source_name_key UNIQUE (name);
ALTER TABLE public.device ADD CONSTRAINT device_uc UNIQUE (data_source_id, code);
ALTER TABLE public.device_model ADD CONSTRAINT device_model_uc UNIQUE (name, manufacturer);
ALTER TABLE public.device_model_type ADD CONSTRAINT device_mode_type_uc UNIQUE (description);
ALTER TABLE public.estimation ADD CONSTRAINT u_estimation UNIQUE (timestamp, fingerprint_id);
ALTER TABLE public.fingerprint ADD CONSTRAINT fingerprint_uc UNIQUE (code, data_source_id);
ALTER TABLE public.tessellation ADD CONSTRAINT tessellation_uc UNIQUE (floor_place_id, data_source_id, type);
ALTER TABLE public.user ADD CONSTRAINT user_uc UNIQUE (code, data_source_id);
ALTER TABLE public.user ADD CONSTRAINT user_uc2 UNIQUE (username, data_source_id);
ALTER TABLE public.user_type ADD CONSTRAINT user_type_uc UNIQUE (description);
ALTER TABLE public.user_type ADD CONSTRAINT user_type_pkey PRIMARY KEY (id);
ALTER TABLE public.user
    ADD FOREIGN KEY (type_id)
    REFERENCES public.user_type (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.user
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.fingerprint
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.fingerprint
    ADD FOREIGN KEY (user_id)
    REFERENCES public.user (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.fingerprint
    ADD FOREIGN KEY (acquired_at_tile_place_id)
    REFERENCES public.tile (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.fingerprint
    ADD FOREIGN KEY (device_id)
    REFERENCES public.device (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.fingerprint
    ADD FOREIGN KEY (preceded_by_fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.fingerprint
    ADD FOREIGN KEY (followed_by_fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.cell_detection
    ADD FOREIGN KEY (cell_id)
    REFERENCES public.cell (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.cell_detection
    ADD FOREIGN KEY (observation_cellular_fingerprint_id)
    REFERENCES public.observation_cellular (fingerprint_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.ap_detection
    ADD FOREIGN KEY (ap_id)
    REFERENCES public.ap (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.ap_detection
    ADD FOREIGN KEY (observation_wifi_fingerprint_id)
    REFERENCES public.observation_wifi (fingerprint_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.bluetooth_detection
    ADD FOREIGN KEY (bluetooth_device_id)
    REFERENCES public.bluetooth_device (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.bluetooth_detection
    ADD FOREIGN KEY (observation_bluetooth_fingerprint_id)
    REFERENCES public.observation_bluetooth (fingerprint_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.cell_data_source
    ADD FOREIGN KEY (cell_id)
    REFERENCES public.cell (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.cell_data_source
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.ap_data_source
    ADD FOREIGN KEY (ap_id)
    REFERENCES public.ap (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.ap_data_source
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.bluetooth_device_data_source
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.bluetooth_device_data_source
    ADD FOREIGN KEY (bluetooth_device_id)
    REFERENCES public.bluetooth_device (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.place_data_source
    ADD FOREIGN KEY (place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.place_data_source
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.contains
    ADD FOREIGN KEY (container_place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.contains
    ADD FOREIGN KEY (contained_place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.building
    ADD FOREIGN KEY (place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.adjacent_to_building
    ADD FOREIGN KEY (building_1_place_id)
    REFERENCES public.building (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.adjacent_to_building
    ADD FOREIGN KEY (building_2_place_id)
    REFERENCES public.building (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.floor
    ADD FOREIGN KEY (place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.floor
    ADD FOREIGN KEY (above_of_floor_place_id)
    REFERENCES public.floor (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.floor
    ADD FOREIGN KEY (below_of_floor_place_id)
    REFERENCES public.floor (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.site
    ADD FOREIGN KEY (place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.tile
    ADD FOREIGN KEY (place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.tile
    ADD FOREIGN KEY (tessellation_id)
    REFERENCES public.tessellation (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.adjacent_to_tile
    ADD FOREIGN KEY (tile_1_place_id)
    REFERENCES public.tile (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.adjacent_to_tile
    ADD FOREIGN KEY (tile_2_place_id)
    REFERENCES public.tile (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.estimation
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.predicted_at
    ADD FOREIGN KEY (place_id)
    REFERENCES public.place (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.predicted_at
    ADD FOREIGN KEY (estimation_id)
    REFERENCES public.estimation (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.device
    ADD FOREIGN KEY (device_model_id)
    REFERENCES public.device_model (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.device
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.device_model
    ADD FOREIGN KEY (type_id)
    REFERENCES public.device_model_type (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.tessellation
    ADD FOREIGN KEY (floor_place_id)
    REFERENCES public.floor (place_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.tessellation
    ADD FOREIGN KEY (data_source_id)
    REFERENCES public.data_source (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.observation_cellular
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.observation_wifi
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.observation_bluetooth
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.observation_gnss
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.observation_imu
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.fingerprint (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE public.observation_imu_accelerometer
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.observation_imu (fingerprint_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.observation_imu_gyroscope
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.observation_imu (fingerprint_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.observation_imu_magnetometer
    ADD FOREIGN KEY (fingerprint_id)
    REFERENCES public.observation_imu (fingerprint_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;
	

