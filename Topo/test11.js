var map;
function initialize() {
  // Create a simple map.
  map = new google.maps.Map(document.getElementById('map-canvas'), {
    zoom: 4,
    center: {lat: -28, lng: 137.883}
  });

  // Load a GeoJSON from the same server as our demo.
  map.data.loadGeoJson('https://storage.googleapis.com/maps-devrel/google.json');
}

google.maps.event.addDomListener(window, 'load', initialize);