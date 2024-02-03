#!/usr/bin/bash
# Usage: localia_home_locations.sh <project_id>
#
# This script pulls visitor location information

SQL=$(printf "
with visitors as (
	select
		ad_id,
		state,
		county,
		tract,
		block_group,
		state || county || tract || block_group as block_fips,
		row_number() over (partition by ad_id order by date desc) as rn
	from \`projects.visitors-$1\`
),
visit_counts as (
	select
		block_fips,
		count(*) as visit_count
	from visitors a
	inner join \`projects.focal-visits-$1\` b
	on a.ad_id = b.ad_id
	group by block_fips
),

block_counts as (
	select
		state,
		county,
		tract,
		block_group,
		block_fips,
		count(distinct(ad_id)) as visitor_count
	from visitors
	where rn = 1
	group by state, county, tract, block_group, block_fips
)
select
	a.state,
	a.county,
	a.tract,
	a.block_group,
	a.block_fips,
	a.visitor_count as device_count,
	c.visit_count as raw_visit_count,
	b.summary_level,
	st_simplify(b.geometry, 10) geography,
	st_centroid(b.geometry) as centroid
from block_counts a
inner join geofacts.geographies b
on a.block_fips = b.state || b.county || b.tract || b.block_group
and b.summary_level = 'BLOCKGROUP'
left join visit_counts c
on a.block_fips = c.block_fips
" %s)

bq query --use_legacy_sql=false --max_rows=1000000 --format=csv "$SQL"
