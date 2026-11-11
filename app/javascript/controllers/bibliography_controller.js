import { Controller } from "@hotwired/stimulus"

// Number of entries above which the list becomes collapsible
const TOGGLE_THRESHOLD = 5
// Index of the last entry that stays visible while the list is collapsed
const TOGGLE_INDEX = 2

// Loads the references that cite this document and renders them as a bibliography
export default class extends Controller {
  static targets = ["list", "toggleText"]
  static values = { path: String, parentId: String, sort: String }

  connect() {
    // Turbo may restore a cached page that already has the bibliography rendered
    if (this.listTarget.childElementCount > 0) return

    this.load()
  }

  async load() {
    const url = new URL(this.pathValue, window.location.origin)
    url.searchParams.append("f[related_document_id_ssim][]", this.parentIdValue)
    url.searchParams.append("f[format_main_ssim][]", "Reference")
    url.searchParams.append("sort", this.sortValue)
    url.searchParams.append("format", "json")
    url.searchParams.append("rows", "1000")

    const response = await fetch(url, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const { data } = await response.json()
    if (data.length === 0) return

    const collapsible = data.length > TOGGLE_THRESHOLD
    const items = data.map((entry, index) => this.itemTemplate(entry, collapsible && index > TOGGLE_INDEX))
    this.listTarget.insertAdjacentHTML("beforeend", items.join(""))
    if (collapsible) this.listTarget.insertAdjacentHTML("beforeend", this.toggleButtonTemplate())

    this.element.style.display = ""
  }

  toggle(event) {
    const expanded = event.currentTarget.classList.toggle("bibliography-expanded")

    this.listTarget.querySelectorAll(".hide-bibliography").forEach((el) => {
      el.style.display = expanded ? "block" : ""
    })
    this.toggleTextTarget.textContent = expanded ? "Collapse bibliography" : "Expand bibliography"
  }

  itemTemplate(entry, hidden) {
    const classes = hidden ? "bibliography-body hide-bibliography" : "bibliography-body"
    // The formatted bibliography may contain HTML, which should be rendered
    const formatted = entry.attributes.formatted_bibliography_ts.attributes.value

    return `<p class="${classes}">${formatted} <a href="${entry.links.self}">[View full reference]</a></p>`
  }

  toggleButtonTemplate() {
    return `<button type="button" class="btn btn-primary bibliography-button" data-action="bibliography#toggle">` +
      `<span data-bibliography-target="toggleText">Expand bibliography</span> ` +
      `<span class="bibliography-icon">»</span>` +
      `</button>`
  }
}
