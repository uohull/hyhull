module Hyhull
  module Geo
    class Coordinate 
      attr_accessor :longitude, :latitude, :altitude

      def initialize(longitude, latitude, altitude)
       @longitude = !longitude.nil? ? longitude : 0.000000
       @latitude = !latitude.nil? ? latitude : 0.000000
       @altitude = !altitude.nil? ? altitude : 0.00
      end 

      def lat_long_alt_str
        return @latitude + "," + @longitude + "," + @altitude
      end

      def long_late_alt_str
        return @longitude + "," + @latitude + "," + @altitude
      end
    end
  end
end