import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const image = this.element.querySelector("img")

    if (!image) return

    if (image.complete) {
      this.loaded()
    }
  }

  loaded() {
    this.element.classList.add("is-loaded")
  }
}
