explain 
with recursive tab as(
    select followed_by_fingerprint_id as f_id
	from fingerprint
	where fingerprint.id=(select id from fingerprint as f1 where exists (select *
			                                                             from fingerprint as f2
			                                                             where f2.id=f1.id and f2.followed_by_fingerprint_id != f2.id) order by random() limit 1)
	
	union all
	
	select followed_by_fingerprint_id as f_id
	from tab, fingerprint
	where tab.f_id=fingerprint.id and followed_by_fingerprint_id!=tab.f_id
)
select f_id, observation_imu_gyroscope.epoch,observation_imu_accelerometer.epoch, observation_imu_magnetometer.epoch
from tab 
join observation_imu on tab.f_id=observation_imu.fingerprint_id 
join observation_imu_gyroscope on observation_imu_gyroscope.fingerprint_id=tab.f_id
join observation_imu_accelerometer on observation_imu_accelerometer.fingerprint_id=tab.f_id
join observation_imu_magnetometer on observation_imu_magnetometer.fingerprint_id=tab.f_id
where is_valid=true