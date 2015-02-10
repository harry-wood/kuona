set -0

# Bash script to fetch villages data in Mali
#  - fetched as several .osm files for different data types
#  - merged into one using osmconvert
#  - centroid nodes only using osmconvert
#  - converted to CSV using osmconvert
#
#  ...but the whole thing couldve been done by Overpass

#These steps can actually be done as
# one magical OverpassAPI query.

#xapi="http://jxapi.osm.rambler.ru/xapi/api/0.6/*"
#xapi="http://jxapi.openstreetmap.org/xapi/api/0.6/*"
xapi="http://www.overpass-api.de/api/xapi?*"

#mali
bbox="[bbox=-12.46545,9.4758,6.34314,25.74516]"

# test region
#bbox="[bbox=-4.7010513,14.5520723,-4.5533712,14.637127]"

echo "calling xapi for places"
wget $xapi[place=*]$bbox -O "places.osm"
echo "calling xapi for residential landuse"
wget $xapi[landuse=*]$bbox -O "landuse.osm"
wget $xapi[building=*]$bbox -O "buildings.osm"
wget $xapi[barrier=*]$bbox -O "barriers.osm"


#echo "adding fake version=1"
#./osmconvert places.osm --fake-version > places-fv.osm
#./osmconvert residential.osm --fake-version > residential-fv.osm

./osmconvert places.osm landuse.osm buildings.osm barriers.osm -o=places-ways-nodes.osm


echo "converting to nodes"
./osmconvert places-ways-nodes.osm --all-to-nodes  >places-nodes.osm
#./osmconvert places-ways-nodes.osm --all-to-nodes | grep -v "<node .*/>"  >places-nodes.osm

echo "converting to CSV"
./osmconvert places-nodes.osm --csv="@lat @lon name" >places.csv

echo "DONE places.csv"
