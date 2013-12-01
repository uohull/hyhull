$(document).ready(function(){
  initialize();
})

function initialize() {

  // Small Google Map Preview
  // Lets check for the map_canvas before we continue...
  if ( $("#map_canvas").length ) {
    displayMap(); 
  }

  // Full Screen Map Canvas DIV
  full_screen_canvas = "full_screen_map_canvas"
  // Google Map Preview - Driven from KML
  // Lets check for full_screen_map_canvas
  if ( $("#" + full_screen_canvas).length ) {
    map_data_url = $("#" + full_screen_canvas).data("url");

    if (typeof map_data_url != 'undefined') {
      displayMapFromFileURL(map_data_url, full_screen_canvas);
    }
  }

}


/*
 * displayMapFromFileURL(map_file_url, map_canvas)
 * This method allows the passing of map_file_url and map_canvas (container div for map)
 * Calls the Google Maps API Class google.maps.KmlLayer
 */
function displayMapFromFileURL(map_file_url, map_canvas) {
  var myLatlng = new google.maps.LatLng(53.771152,0.368149);
  var myOptions = {
    zoom: 1,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }

  var map = new google.maps.Map(document.getElementById(map_canvas), myOptions);

  var georssLayer = new google.maps.KmlLayer(map_file_url);
  georssLayer.setMap(map);
}



function displayMap() {
 var LINE_STRING_CONST = "LineString";
 var POLYGON_CONST = "Polygon";
 var POINT_CONST = "Point";

 coords = getCoordinates();
 coords_type = getCoordinatesType();
 coords_title = getCoordinatesTitle();
 coords_count = coords.length;

 //Primarily we check the coords_count for display purposes (a single coordinate polygon/polyline is still a singlePlacemark)
 if (coords_count == 1) {
  singlePlacemark(coords[0].longitude, coords[0].latitude, coords_title)
 }
 else if (coords_count > 1) {
   //If over 1 coords, we then test if its a LINE_STRING_CONST, otherwise default to Polygon...
   if (coords_type == LINE_STRING_CONST)
   {
     polylinePlacemarks(coords, coords_title)
   }
   else
   {
     polygonPlacemarks(coords, coords_title)
   }
 }

}

function singlePlacemark(longitude, latitude, coords_title) {
  var myLatlng = new google.maps.LatLng( latitude, longitude);

  var myOptions = {
    zoom: 10,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
  }
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

  var marker = new google.maps.Marker({
      position: myLatlng,
      title: coords_title
  });

  addInfoWindowTextMarkerToMap(marker, map, coords_title); 
}


function polylinePlacemarks(coords, coords_title) {

 var firstPoint = new google.maps.LatLng(coords[0].latitude, coords[0].longitude);

 var myOptions = {
   zoom: 5,
   center: firstPoint,
   mapTypeId: google.maps.MapTypeId.ROADMAP
  };

 var polyline;
 var polyline_coords = [];
 var latlngbounds =  new google.maps.LatLngBounds();

 var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

  coords_count = coords.length;

  //Add the coords to the polygone object...
  for(var i=0; i<coords_count; i++) {   
     polyline_coords.push(new google.maps.LatLng(coords[i].latitude, coords[i].longitude));
     latlngbounds.extend(new google.maps.LatLng(coords[i].latitude, coords[i].longitude));     
  }

  map.setCenter(latlngbounds.getCenter());
  map.fitBounds(latlngbounds);

  polyline = new google.maps.Polyline({
    path: polyline_coords,
    strokeColor: "#3300CC",
    strokeOpacity: 1.0,
    strokeWeight: 2
  });

  var marker = new google.maps.Marker({
      position: firstPoint,
      title: coords_title
   });
 
  addInfoWindowTextMarkerToMap(marker, map, coords_title);
  polyline.setMap(map);
}



function polygonPlacemarks(coords, coords_title) {

 var myLatLng = new google.maps.LatLng(coords[0].latitude, coords[0].longitude);

 var myOptions = {
   zoom: 5,
   center: myLatLng,
   mapTypeId: google.maps.MapTypeId.ROADMAP
  };

 var polygon_area;
 var polygon_coords = [];
 var latlngbounds =  new google.maps.LatLngBounds();


 var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

  coords_count = coords.length;

  
  //Add the coords to the polygone object...
  for(var i=0; i<coords_count; i++) {   
     polygon_coords.push(new google.maps.LatLng(coords[i].latitude, coords[i].longitude));
     latlngbounds.extend(new google.maps.LatLng(coords[i].latitude, coords[i].longitude));     
  }

  map.setCenter(latlngbounds.getCenter());
  map.fitBounds(latlngbounds);

  polygon_area = new google.maps.Polygon({
    paths: polygon_coords,
    strokeColor: "#0000FF",
    strokeOpacity: 0.8,
    strokeWeight: 2,
    fillColor: "#0000FF",
    fillOpacity: 0.35
  });

  var marker = new google.maps.Marker({
      position: latlngbounds.getCenter(),
      title: coords_title
   });
 
  addInfoWindowTextMarkerToMap(marker, map, coords_title);

  polygon_area.setMap(map);
}

function addInfoWindowTextMarkerToMap(marker, map, text) {

 if (text.length > 0) {
   info_text = '<div id="content"><p>' + text + '</p></div>';

   var infowindow = new google.maps.InfoWindow({
    content: info_text
   });  

   google.maps.event.addListener(marker, 'mouseover', function() {
   infowindow.open(map,marker);
   });
  }

  marker.setMap(map);
}


function getCoordinates() {

  var array_of_coord_objs = [];

  //Check that field containing coordinates exists....
  if ($("#document_fedora_coordinates").val() != undefined)
  {
    var coordinates = $("#document_fedora_coordinates").val();
    var coordinates_array = coordinates.split(" ");
    var count = coordinates_array.length

    for(var i=0; i<count; i++) {
      
      var coords = coordinates_array[i].split(",")

      if (coords.length == 2) 
      {
        //var coord = new coordinate(coords[0], coords[1], "");
        array_of_coord_objs.push( new coordinate(coords[0], coords[1], "") );
      }
      else if (coords.length == 3)
      {
         array_of_coord_objs.push( new coordinate(coords[0], coords[1], coords[2]) );
      }
     }    
  }
  return array_of_coord_objs;
}

function getCoordinatesTitle() {
  var coordinates_title = "";

  if ($("#document_fedora_coordinates_title").val() != undefined)
  {
    coordinates_title = $("#document_fedora_coordinates_title").val();
  }

  return coordinates_title;
}

function getCoordinatesType() {
  var coordinates_type = "";

  if ($("#document_fedora_coordinates_type").val() != undefined)
  {
    coordinates_type = $("#document_fedora_coordinates_type").val();
  }

  return coordinates_type;
}


/*
  coordinate object (simply longitude,latitude,altitude) 
*/
 function coordinate(longitude, latitude, altitude)
 {
  this.longitude=longitude;
  this.latitude=latitude;
  this.altitude;
 }