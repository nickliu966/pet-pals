import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async connect() {
    const [{ Map }, { AdvancedMarkerElement }, _] = await Promise.all([
      google.maps.importLibrary("maps"),
      google.maps.importLibrary("marker"),
      google.maps.importLibrary("places"),
    ]);

    const map = new Map(document.getElementById("minimap"), {
      center: { lat: 41.8781, lng: -87.6298 },
      zoom: 11,
      mapId: "DEMO_MAP_ID",
    });

    const marker = new AdvancedMarkerElement({ map });

    const placeAutocomplete = new google.maps.places.PlaceAutocompleteElement({});
    placeAutocomplete.placeholder = "Search for a park, trail, or address...";
    placeAutocomplete.style.width = "100%";

    document.getElementById("search-box-container").appendChild(placeAutocomplete);

    placeAutocomplete.addEventListener("gmp-select", async ({ placePrediction }) => {
      const place = placePrediction.toPlace();

      await place.fetchFields({
        fields: ["displayName", "formattedAddress", "location", "viewport"],
      });

      if (place.viewport) {
        map.fitBounds(place.viewport);
      } else {
        map.setCenter(place.location);
        map.setZoom(15);
      }

      marker.position = place.location;

      document.getElementById("walk_location_name_box").value =
        place.formattedAddress || place.displayName || "";

      document.getElementById("walk_latitude_box").value = place.location.lat();
      document.getElementById("walk_longitude_box").value = place.location.lng();
    });
  }
}
