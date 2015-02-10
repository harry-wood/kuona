set -0
./fetchplaces.sh

rm mali-crowdsource.gpx
wget http://stuff.povaddict.com.ar/mali-crowdsource.gpx

ruby missingplaces.rb mali-crowdsource.gpx
