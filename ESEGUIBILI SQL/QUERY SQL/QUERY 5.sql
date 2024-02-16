explain analyze
select tile.place_id, tile.type
from tile
where exists (select *
			from fingerprint
			join estimation on estimation.fingerprint_id=fingerprint.id
			join predicted_at on predicted_at.estimation_id=estimation.id
			join observation_cellular on observation_cellular.fingerprint_id=fingerprint.id
			join cell_detection on observation_cellular_fingerprint_id=fingerprint.id
			where is_valid=true and cell_id=(SELECT cell.id FROM cell ORDER BY RANDOM() LIMIT 1) and predicted_at.place_id=tile.place_id)