import { Controller } from "@hotwired/stimulus"

// Switches the site search form between searching exhibits by title and searching all items
export default class extends Controller {
  static targets = ["menu", "button", "option"]
  static values = { enabled: String }

  connect() {
    this.showOption(this.enabledValue)
    this.menuTarget.style.display = ""
  }

  select(event) {
    event.preventDefault()

    this.showOption(event.params.option)
    this.buttonTarget.textContent = event.params.buttonText
  }

  showOption(id) {
    this.optionTargets.forEach((option) => {
      option.style.display = option.id === id ? "" : "none"
    })
  }
}
