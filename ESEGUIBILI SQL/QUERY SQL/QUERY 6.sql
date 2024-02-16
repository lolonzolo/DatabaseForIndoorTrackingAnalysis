
drop table if exists tab;

create temporary table tab as
select p1.name as c1, p2.name as c2, p3.name as c3
from place as p1 
join site on site.place_id=p1.id
join contains as c1 on c1.contained_place_id=site.place_id
join floor on floor.place_id=c1.container_place_id
join place as p2 on floor.place_id=p2.id
join contains as c2 on floor.place_id=c2.contained_place_id
join place as p3 on p3.id=c2.container_place_id
join contains as c3 on site.place_id=c3.container_place_id
LIMIT 1;




explain 
with RECURSIVE reachable AS (
	SELECT
		adjacent_to_tile.tile_1_place_id,
		adjacent_to_tile.tile_2_place_id
	FROM
		adjacent_to_tile
	WHERE
		walkable and tile_1_place_id = (select contains_tile.contained_place_id
										 from contains as contains_tile
										 		join place as place_site on place_site.id = contains_tile.container_place_id
										 		join site on place_site.id = site.place_id
										 		join contains as contained_in_floor on contained_in_floor.contained_place_id = place_site.id
												join place as place_floor on place_floor.id = contained_in_floor.container_place_id
												join contains as contained_in_building on contained_in_building.contained_place_id = place_floor.id
												join place as place_building on place_building.id = contained_in_building.container_place_id	
										 		join place_data_source on place_data_source.place_id = place_site.id
												join data_source on data_source.id = place_data_source.data_source_id
										 where place_site.name = (select c1 from tab limit 1) and place_floor.name = (select c2 from tab  limit 1) and place_building.name = (select c3 from tab limit 1)
									     limit 1)
	UNION
		SELECT
			next.tile_1_place_id,
			next.tile_2_place_id
		FROM
			reachable as prev
				JOIN adjacent_to_tile as next ON next.tile_1_place_id = prev.tile_2_place_id and next.walkable
),
site_floor_building_info as (
select
	place_building.name as building_name,
	place_floor.name as floor_name, 
	place_site.name as site_name, 
	place_site.id as site_id
from 
	place as place_site
		join site on place_site.id = site.place_id
		join contains as contained_in_floor on contained_in_floor.contained_place_id = place_site.id
		join place as place_floor on place_floor.id = contained_in_floor.container_place_id
		join contains as contained_in_building on contained_in_building.contained_place_id = place_floor.id
		join place as place_building on place_building.id = contained_in_building.container_place_id	
		join place_data_source on place_site.id = place_data_source.place_id
		join data_source on data_source.id = place_data_source.data_source_id

)
select distinct
	info_from.building_name as starting_building,
	info_from.floor_name as starting_floor, 
	info_from.site_name as starting_site, 
	info_to.building_name as ending_building,
	info_to.floor_name as ending_floor,
	info_to.site_name as ending_site
from site_floor_building_info as info_from
		join place_data_source on place_data_source.place_id = info_from.site_id
		join data_source on data_source.id = place_data_source.data_source_id
		join contains as contains_tile_from on contains_tile_from.container_place_id = info_from.site_id
		join contains as contains_tile_to on contains_tile_to.container_place_id != info_from.site_id
		join reachable on reachable.tile_2_place_id = contains_tile_to.contained_place_id
		join site_floor_building_info as info_to on info_to.site_id = contains_tile_to.container_place_id
where info_from.site_name = (select c1 from tab  limit 1) and info_from.floor_name = (select c2 from tab  limit 1) and info_from.building_name = (select c3 from tab  limit 1);