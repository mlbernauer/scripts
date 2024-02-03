STATE=$1
GEO=$(cat $2)
RADIUS=$3

read -r -d '' SQL <<-EOM
select
	ad_id,
	visit_start,
	duration,
	st_x(centroid) AS lon,
	st_y(centroid) AS lat
FROM mobility.visits
WHERE state = '$STATE'
AND ST_WITHIN(centroid, ST_BUFFER(ST_GEOGFROMGEOJSON('$GEO'),$RADIUS))
EOM

bq query --format=csv --max_rows=10000000 --use_legacy_sql=false "$SQL"
