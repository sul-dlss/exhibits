import { Controller } from "@hotwired/stimulus"

// Loads and lists the documents cited by a reference
export default class extends Controller {
  static targets = ["list"]
  static values = { path: String, documentIds: Array }

  connect() {
    // Turbo may restore a cached page that already has the list rendered
    if (this.listTarget.childElementCount > 0) return

    this.load()
  }

  async load() {
    const response = await fetch(this.pathValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: new URLSearchParams({ ids: this.documentIdsValue.join(" "), format: "json" })
    })
    if (!response.ok) return

    const documents = await response.json()
    const items = documents.map((doc) => `<li class="cited-documents-body"> <a href="${doc.id}">${doc.title_display}</a></li>`)
    this.listTarget.insertAdjacentHTML("beforeend", items.join(""))
  }
}
