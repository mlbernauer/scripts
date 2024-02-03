STATE=$1
GEO=$(jq -c '.features[0].geometry' $2)

read -r -d '' SQL <<-EOM
select
	ad_id,
	visit_start,
	duration,
	st_x(centroid) AS lon,
	st_y(centroid) AS lat
FROM mobility.visits
WHERE state = '$STATE'
AND ST_WITHIN(centroid, ST_GEOGFROMGEOJSON('$GEO'))
EOM

bq query --dry_run --format=csv --max_rows=10000000 --use_legacy_sql=false "$SQL"
