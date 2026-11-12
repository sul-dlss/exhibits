import { Controller } from "@hotwired/stimulus"

// Lets curators pick a druid from an <auto-complete> and shows its index status in a table
export default class extends Controller {
  static targets = ["table"]
  static values = { url: String }

  preventSubmit(event) {
    event.preventDefault()
  }

  add(event) {
    const value = event.relatedTarget.value
    const option = event.currentTarget.querySelector(`[data-autocomplete-value="${CSS.escape(value)}"][role="option"]`)
    if (option) this.addRow(option.dataset.autocompleteValue)
  }

  addRow(druid) {
    if (this.row(druid)) return

    const row = document.createElement("tr")
    row.dataset.indexStatusId = druid
    const druidCell = document.createElement("td")
    druidCell.textContent = druid
    const statusCell = document.createElement("td")
    statusCell.dataset.behavior = "index-item-status"
    row.append(druidCell, statusCell)

    this.tableTarget.tBodies[0].append(row)
    this.tableTarget.style.display = ""

    this.updateStatus(druid)
  }

  row(druid) {
    return this.tableTarget.querySelector(`tr[data-index-status-id="${CSS.escape(druid)}"]`)
  }

  async updateStatus(druid) {
    const response = await fetch(`${this.urlValue}/${encodeURIComponent(druid)}`, {
      headers: { Accept: "application/json" }
    })
    if (!response.ok) return

    const { status } = await response.json()
    const row = this.row(druid)
    if (!status.ok) row.classList.add("danger")
    row.querySelector('td[data-behavior="index-item-status"]').textContent = status.ok ? "Published" : status.message
  }
}
