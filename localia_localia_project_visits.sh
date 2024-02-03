#!/usr/bin/bash
bq query --use_legacy_sql=false --format=csv --max_rows=5000000 "select ad_id, state, visit_start, duration, centroid lat from \`projects.all-visits-$1\` where focal_ind" > $1.csv
