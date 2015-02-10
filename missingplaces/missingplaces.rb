require "nokogiri"
include Math

STDOUT.sync = true

#
#  This script takes a GPX file which was output from
#  kuona, representing places people clicked when they
#  thought they could see a village in the imagery
#
#  It also takes a CSV file representing places nodes
#  from OSM (i.e. data for villages already in OSM)
#
#  It then performs a spatial buffer operation to drop
#  any GPX points for villages which seem to be in
#  OSM already.
#
#  There's probably a two line GRASS command which 
#  could have done this. Some nice bare ruby logic but
#  there's probably some GRASS two-liner which could
#  have done this :-)
#

Radius = 6371  # rough radius of the Earth, in kilometers
Buffer = 0.1
OutputGPX = "missingplaces-new.gpx"

# SAX parser for processing a GPX file
# calls gotPoint on each <wpt> element
# subclass of Nokogiri::XML::SAX::Document
class MyDoc < Nokogiri::XML::SAX::Document
  def start_element name, attrs = []
    if name=="wpt"
   
       $count+=1

       lat = attrs[0][1].to_f
       lon = attrs[1][1].to_f
       puts lat.to_s + " " + lon.to_s if $count<2
       gotPoint(lat,lon)
                      # test region
                      #   if lon>-4.7010513 and
                      #      lon<-4.5533712 and
                      #      lat>14.5520723 and
                      #      lat<14.637127

    end
  end
 
  #def end_element name
  #  puts "ending: #{name}"
  #end
end

#quick test if two points are within 0.02 degrees of eachother
def is_close(start_coords, end_coords)
  lat1, long1 = deg2rad *start_coords
  lat2, long2 = deg2rad *end_coords
  if (long1 - long2 < 0.02) and 
     (long1 - long2 > -0.02) and 
     (lat1 - lat2 < 0.02) and 
     (lat1 - lat2 > -0.02)
    return true
  else
    return false
  end
end
 
#great circle distance betwen two points
def spherical_distance(start_coords, end_coords)
  lat1, long1 = deg2rad *start_coords
  lat2, long2 = deg2rad *end_coords
  2 * Radius * asin(sqrt(sin((lat2-lat1)/2)**2 + cos(lat1) * cos(lat2) * sin((long2 - long1)/2)**2))
end
 
def deg2rad(lat, long)
  [lat * PI / 180, long * PI / 180]
end

#Get nearby places (OSM villages)
#Do this by looking up any places within the same grid
#square, or neighbouring grid squares
def get_close_places(lat,lon)

  square = get_square(lat,lon)
  sqlat = square[0]
  sqlon = square[1]
  places = []
  places.concat $places[ [sqlat-1,sqlon+1 ] ] || []
  places.concat $places[ [sqlat  ,sqlon+1 ] ] || []
  places.concat $places[ [sqlat+1,sqlon+1 ] ] || []
  places.concat $places[ [sqlat-1,sqlon ] ]   || []
  places.concat $places[ [sqlat  ,sqlon ] ]   || []
  places.concat $places[ [sqlat+1,sqlon ] ]   || []
  places.concat $places[ [sqlat-1,sqlon-1 ] ] || []
  places.concat $places[ [sqlat  ,sqlon-1 ] ] || []
  places.concat $places[ [sqlat+1,sqlon-1 ] ] || []

  return places 
end

#decide which square a lat lon coordinate is within
#reutrn the unique square reference which is actually
#a [lat,lon] pair just with the values rounded.
def get_square(lat,lon)
  return [ ((lat * 100.0).round)/100.0,
           ((lon * 100.0).round)/100.0 ]
           
end

#Called for each waypoint found in the input GPX
#(where people think they've seen villages)
def gotPoint(lat,lon)

  nearby_place_found = false

  # call get_close_places to get nearby OSM places
  # (as per the grid squares)
  get_close_places(lat,lon).each do |place|

    #for each place
    plat,plon,name = place

    if is_close([lat, lon], [plat.to_f, plon.to_f])
      #It's vaguely close by. Let's do the actual distance calculation
      dist = spherical_distance([lat, lon], [plat.to_f, plon.to_f])
      if dist < Buffer
        nearby_place_found = true
        break
      end
    end
  end
  if not nearby_place_found
    #No nearby places found (which is the intersting case!)
    $missingcount+=1
    puts "gpx point " + $count.to_s + " - No nearby place.  " + lat.to_s + " " +  lon.to_s #+ " " + shortest_dist.to_s + "km (" + shortest_place.to_s + " " + splat.to_s + " " + splon.to_s + ")"

    #Write a waypoint to the output GPX file
    File.open(OutputGPX, 'a') {|f| f.write( "<wpt lat=\"" + lat.to_s + "\" lon=\"" + lon.to_s + "\"></wpt>\n" ) }

  end
end

#Load openstreetmap places (villages) data from CSv file
#can populate the grid squares index
def load_places_CSV()
  puts "loading CSV"
  $places = {}
  File.open('places.csv').each do |line|
    place = line.split("\t") 
    plat,plon,name = place
    if plat.to_f>14.04
      square = get_square(plat.to_f, plon.to_f)
      if $places[square].nil? 
         p square
         $places[square] = []
      end
      $places[square] << place 
    end
  end
  puts $places.size.to_s + " places loaded"
end

start_time = Time.now

$count = 0
$missingcount = 0
$places = {} 
load_places_CSV()



filename = ARGV[0]
raise('no file param') if filename.nil?
 
# Create our parser
parser = Nokogiri::XML::SAX::Parser.new(MyDoc.new)
 
File.open(OutputGPX, 'w') {|f| f.write( "<gpx>\n" ) }

# Send some XML to the parser
parser.parse(File.open(ARGV[0]))

File.open(OutputGPX, 'a') {|f| f.write( "</gpx>\n" ) }

report = $count.to_s + " points processed from GPX file\n" +
         $missingcount.to_s + " points found a long way from anything\n" +
         "Excution time:" + (Time.now - start_time).round.to_s + " s"

puts report
File.open(OutputGPX, 'a') {|f| f.write( "<!--\n" + report + "\n-->" ) }
