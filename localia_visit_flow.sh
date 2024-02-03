#!/usr/bin/bash
# Usage: ./localia_visit_flows.sh <project_id>
# 
# This script is used to download visit flows from localia project

SQL=$(printf "
with focal_fips as (
	select distinct
		state || county || tract || block_group as fips
	from \`projects.focal-visits-%s\`
),
flows as (
	select
		state_lag || county_lag || tract_lag || block_group_lag as fips_lag,
		state_lead || county_lead || tract_lead || block_group_lead  as fips_lead,
		ad_id
	from \`projects.flow-%s\` 
),
coming_from as (
	select
		'coming_from' direction,
		fips_lag as fips,
		count(distinct(ad_id)) as device_count
	from flows
	where fips_lead in (select fips from focal_fips)
	group by direction, fips_lag
),
going_to as (
	select
		'going_to' direction,
		fips_lead as fips,
		count(distinct(ad_id)) as device_count
	from flows
	where fips_lag in (select fips from focal_fips)
	group by direction, fips_lead
),
all_flows as (
	select
		*
	from coming_from
	union all
	select
		*
	from going_to
)
select
	a.*,
	b.geometry as geometry,
	st_centroid(b.geometry) as centroid
from all_flows a
inner join geofacts.geographies b
on a.fips = b.state || b.county || b.tract || b.block_group
where b.summary_level = 'BLOCKGROUP';" "$1" "$1")

bq query --format=csv --use_legacy_sql=false --max_rows=1000000 "$SQL"
