#!/usr/bin/env python3

import requests
import osm2geojson
import json
import argparse
import sys

# https://gis.stackexchange.com/questions/332844/overpass-api-returns-points-instead-of-polygons

def get_place_details(query):
    url = f'https://nominatim.openstreetmap.org/search?q={query}&format=json&polygon_geojson=1&addressdetails=1'
    response = requests.get(url).json()
    return response

def get_footprint_from_relation_id(relation_id):
    typ,rid = relation_id.split(':')
    query = f'[out:xml][timeout:25];({typ}({rid}););out geom;'
    url = f'https://overpass-api.de/api/interpreter?data={query}'
    response = requests.get(url)
    string  = response.text.replace('\n','')
    geojson = osm2geojson.xml2geojson(string)
    return geojson

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'Reuturn building geometry')
    parser.add_argument('--query', help = 'Query, can be name or address e.g. "The Treasury Building" OR "301 Gold Ave"', required = True)
    parser.add_argument('--id', help = 'OpenStreetmap Relation ID', required = False)
    parser.add_argument('--result', help = 'Integer describing which result to return', required = False)
    parser.add_argument('--geometry', action = 'store_true')
    args = parser.parse_args()

    if args.query:
        r = get_place_details(args.query)
        if args.result:
            geo = get_footprint_from_relation_id(f"{r[int(args.result)]['osm_type']}:{r[int(args.result)]['osm_id']}")
            if args.geometry:
                print(json.dumps(geo['features'][0]['geometry']))
                sys.exit()
            print(json.dumps(geo))
            sys.exit()
        for i in range(len(r)):
            print(f"{i}: {r[i]['display_name']}")
            print(f"  ID: {r[i]['osm_type']}:{r[i]['osm_id']}")
        sys.exit()

    if args.id:
        r = get_footprint_from_relation_id(args.id)
        print(json.dumps(r))
        sys.exit()
