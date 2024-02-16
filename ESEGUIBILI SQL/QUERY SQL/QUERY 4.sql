explain 
select apd1.observation_wifi_fingerprint_id
from ap_detection as apd1
join observation_wifi as owf1 on apd1.observation_wifi_fingerprint_id=owf1.fingerprint_id
join fingerprint on apd1.observation_wifi_fingerprint_id=fingerprint.id
where owf1.is_valid=true and fingerprint.data_source_id=(SELECT data_source.id FROM data_source ORDER BY RANDOM() LIMIT 1) and exists(select 
			from ap_detection as apd2
			join observation_wifi as owf2 on apd2.observation_wifi_fingerprint_id=owf2.fingerprint_id
			where apd2.ap_id=apd1.ap_id and owf2.is_valid=true and apd2.observation_wifi_fingerprint_id=(SELECT fingerprint.id FROM fingerprint ORDER BY RANDOM() LIMIT 1)
		)