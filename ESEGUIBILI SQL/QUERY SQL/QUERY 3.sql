explain 
WITH RECURSIVE reachable AS (
SELECT adjacent_to_tile.tile_2_place_id  --query iniziale: andiamo a restituire tutte le tile adiacenti alla tile specificata, 1441, che sono walkable
FROM adjacent_to_tile
WHERE walkable AND tile_1_place_id = (SELECT tile.place_id FROM tile ORDER BY RANDOM() LIMIT 1)
UNION

SELECT succ.tile_2_place_id   --per ciascuna delle tile trovate prima, andiamo a iterare sulla tabella adjacent_to_tile... e cosi via
FROM reachable AS prev 
JOIN adjacent_to_tile AS succ ON
succ.tile_1_place_id=prev.tile_2_place_id AND succ.walkable
)
SELECT tile_2_place_id AS reachable_tile_id --estraggo i dati dalla tabella creata con la ricorsione
FROM reachable;

