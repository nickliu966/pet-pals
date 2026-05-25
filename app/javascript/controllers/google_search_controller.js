import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "map",
    "searchBox",
    "locationName",
    "latitude",
    "longitude",
    "placeId"
  ]

  connect() {
    this.initialized = false

    const modal = this.element.closest(".modal")

    if (modal) {
      modal.addEventListener("shown.bs.modal", () => {
        this.initializeGoogleSearch()
      }, { once: true })
    } else {
      this.initializeGoogleSearch()
    }
  }

  async initializeGoogleSearch() {
    if (this.initialized) return
    this.initialized = true

    if (!window.google) {
      console.error("Google Maps JS is not loaded.")
      return
    }

    const [{ Map }, { AdvancedMarkerElement }] = await Promise.all([
      google.maps.importLibrary("maps"),
      google.maps.importLibrary("marker"),
      google.maps.importLibrary("places")
    ])

    const savedLatitude = this.hasLatitudeTarget ? parseFloat(this.latitudeTarget.value) : NaN
    const savedLongitude = this.hasLongitudeTarget ? parseFloat(this.longitudeTarget.value) : NaN

    const hasSavedLocation = !Number.isNaN(savedLatitude) && !Number.isNaN(savedLongitude)

    const initialPosition = hasSavedLocation
      ? { lat: savedLatitude, lng: savedLongitude }
      : { lat: 41.8781, lng: -87.6298 }

    let map = null
    let marker = null

    if (this.hasMapTarget) {
      map = new Map(this.mapTarget, {
        center: initialPosition,
        zoom: hasSavedLocation ? 15 : 11,
        mapId: "DEMO_MAP_ID",
      })

      marker = new AdvancedMarkerElement({
        map: map,
        position: hasSavedLocation ? initialPosition : null,
      })
    }

    const placeAutocomplete = new google.maps.places.PlaceAutocompleteElement({})

    placeAutocomplete.placeholder = "Search for a park, trail, or address..."
    placeAutocomplete.style.width = "100%"

    this.searchBoxTarget.innerHTML = ""
    this.searchBoxTarget.appendChild(placeAutocomplete)

    placeAutocomplete.addEventListener("gmp-select", async ({ placePrediction }) => {
      const place = placePrediction.toPlace()

      await place.fetchFields({
        fields: [
          "id",
          "displayName",
          "formattedAddress",
          "location",
          "viewport"
        ],
      })

      if (!place.location) return

      if (map && marker) {
        if (place.viewport) {
          map.fitBounds(place.viewport)
        } else {
          map.setCenter(place.location)
          map.setZoom(15)
        }

        marker.position = place.location
      }

      if (this.hasLocationNameTarget) {
        this.locationNameTarget.value =
          place.formattedAddress || place.displayName || ""
      }

      if (this.hasLatitudeTarget) {
        this.latitudeTarget.value = place.location.lat()
      }

      if (this.hasLongitudeTarget) {
        this.longitudeTarget.value = place.location.lng()
      }

      if (this.hasPlaceIdTarget) {
        this.placeIdTarget.value = place.id || ""
      }
    })
  }
}
