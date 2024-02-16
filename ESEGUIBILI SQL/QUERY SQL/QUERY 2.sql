
explain 
select tile.place_id, tile.type
from tile
	join tessellation on tile.tessellation_id=tessellation.id 
	join floor on floor.place_id=tessellation.floor_place_id
	join contains on floor.place_id=contains.contained_place_id
where container_place_id=(SELECT building.place_id FROM building ORDER BY RANDOM() LIMIT 1) and not exists (select *
											from fingerprint 
											where is_radio_map=true and acquired_at_tile_place_id=tile.place_id)