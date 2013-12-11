# GeoHelper 
# Provides some helper methods to turn a list of geo-coordinates into a displayable map
#
# display_google_js_map requires the JS file 'google_maps.js'
# display_google_static_map utilises the Google static map function (turns encoded polyline into a static image type map)
#
module GeoHelper

  def include_google_map_api_js
    javascript_include_tag("https://maps.googleapis.com/maps/api/js?key=#{google_maps_key}&sensor=false")
  end

  def display_google_js_map(coordinates, coordinates_type, coordinates_title, dt_title)
    unless coordinates.nil? || coordinates.empty? 
      coordinates = coordinates.first if coordinates.kind_of? Array

      #We first add the javascripts to the includes (Googles API code)   
      content_for :script do
        javascript_include_tag("https://maps.googleapis.com/maps/api/js?key=#{google_maps_key}&sensor=false")
      end 

       #Add coordinates/coordinates_type/coordinates_title to hidden fields to be read by google_maps.js
       map = <<-EOS
       <dt>#{dt_title}</dt>
        <dd>
          <div id="map_canvas" style="width:100%; height:281px"></div>
        </dd>
       #{hidden_field(:document_fedora, :coordinates, :value => coordinates )}
       #{hidden_field(:document_fedora, :coordinates_type, :value => coordinates_type )}
       #{hidden_field(:document_fedora, :coordinates_title, :value => coordinates_title )}
      EOS
      map.html_safe
    end
  end

  
  def display_google_static_map(coordinates, dt_title)
    unless coordinates.nil?
      coordinates = coordinates.first if coordinates.kind_of? Array    
      encoded_polyline =  create_polyline(get_coordinate_list( coordinates ) )

      map = <<-EOS
        <dt>#{dt_title}</dt>
        <dd>
         <img src="#{get_static_google_map_url(encoded_polyline)}" alt="Map">
        </dd>
      EOS
      map.html_safe
    end
  end
  
  def get_static_google_map_url(encoded_polyline)
      map_size = "500x281"
      fillcolor = "0xAA000033"
      color = "0xFFFFFF00"      
      google_maps_url = "https://maps.googleapis.com/maps/api/staticmap?sensor=false&size=#{map_size}&path=fillcolor:#{fillcolor}%7Ccolor:#{color}%7Cenc:#{encoded_polyline[:points]}" 
  end
  
  def create_polyline( coordinate_list )    
    data = []
    coordinate_list.each { |coord|  data << [coord.latitude, coord.longitude]  } 
    Hyhull::Geo::GmapPolylineEncoder.new.encode(data)
  end


  def get_coordinate_list(coordinates)

   #This gets us an array of coords
   coords = coordinates.split(" ")

   #Holding array for our array of coordinates
   coordinate_list = []
  
   coords.each do |coordinate|
     values = coordinate.split(",")     
     long = values[0].to_f
     lat = values[1].to_f
     if values.size == 3 then alt = values[2].to_f end
     coordinate_list << Hyhull::Geo::Coordinate.new(long, lat, alt)
   end

   return coordinate_list  
  end

  private

  def google_maps_key
    return GOOGLE_MAPS_KEY
  end

end
