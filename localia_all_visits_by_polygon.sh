#!/bin/env bash

if [ ! $# -eq 2 ]; then
	echo "Usage: $0 <STATE> <GEOJSONFILE>"
	exit
fi

STATE=$1
GEO=$(jq -c '.features[0].geometry' $2)

read -r -d '' SQL <<-EOM
with tmp as (
	select distinct
		ad_id,
	FROM mobility.visits
	WHERE state = '$STATE'
	AND ST_WITHIN(centroid, ST_GEOGFROMGEOJSON('$GEO'))
)
select
	ad_id,
	visit_start,
	duration,
	st_x(centroid) AS lon,
	st_y(centroid) AS lat,
	case
		when st_within(centroid, ST_GEOGFROMGEOJSON('$GEO'))
		then 1
		else 0
	end as focal_visits
from mobility.visits
where state = '$STATE'
and ad_id in (select ad_id from tmp)
EOM

bq query --dry_run --format=csv --max_rows=10000000 --use_legacy_sql=false "$SQL"
