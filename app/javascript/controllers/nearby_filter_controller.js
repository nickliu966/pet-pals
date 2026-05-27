import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["latitude", "longitude", "status"]

  use(event) {
    event.preventDefault()

    if (!navigator.geolocation) {
      this.showStatus("Your browser does not support location lookup.")
      return
    }

    this.showStatus("Getting your location...")

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.latitudeTarget.value = position.coords.latitude
        this.longitudeTarget.value = position.coords.longitude

        this.showStatus(this.activeStatusText())

        this.element.requestSubmit()
      },
      (error) => {
        console.error("location error", error)
        this.showStatus("Could not get your location. Please allow location access.")
      },
      {
        enableHighAccuracy: false,
        timeout: 10000,
        maximumAge: 60000
      }
    )
  }

  activeStatusText() {
    const radiusSelect = this.element.querySelector("[name='radius_miles']")
    const radius = radiusSelect?.value

    if (radius) {
      const unit = radius === "1" ? "mile" : "miles"
      return `Showing public results within ${radius} ${unit}.`
    }

    return "Showing all public results."
  }

  showStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}
