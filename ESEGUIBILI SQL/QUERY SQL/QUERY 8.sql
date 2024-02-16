CREATE OR REPLACE FUNCTION CharacterizingFP(obj_id integer) 
returns table (id integer, code varchar, rss numeric)
AS $$
DECLARE
	ref_data_source_id integer;
BEGIN
	SELECT data_source_id into ref_data_source_id from fingerprint where fingerprint.acquired_at_tile_place_id = obj_id LIMIT 1;
	RETURN QUERY
		select ap.id as ap_id, ap.code as ap_code, AVG(coalesce(ap_detection.rss, -110)) as rss
		from ap
			join ap_data_source on ap.id = ap_data_source.ap_id
			join data_source on data_source.id = ap_data_source.data_source_id
			left outer join ap_detection on ap.id = ap_detection.ap_id and observation_wifi_fingerprint_id in ( 
				select observation_wifi.fingerprint_id
				from observation_wifi join fingerprint on observation_wifi.fingerprint_id = fingerprint.id
				where fingerprint.acquired_at_tile_place_id = obj_id)
		where ap_data_source.data_source_id = ref_data_source_id
		group by ap.id, ap.code
		order by ap.id;
END;
$$ LANGUAGE plpgsql;

explain analyze
SELECT CharacterizingFP((select tile.place_id from tile order by random() limit 1));