
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.draggedElement = null
  }

  dragStart(event) {
    const row = event.target.closest("[data-field-id]")

    if (!row) return

    this.draggedElement = row
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", row.dataset.fieldId)

    row.classList.add("opacity-50")
  }

  dragOver(event) {
    event.preventDefault()

    const targetRow = event.target.closest("[data-field-id]")

    if (!targetRow || !this.draggedElement || targetRow === this.draggedElement) {
      return
    }

    const rect = targetRow.getBoundingClientRect()
    const insertAfter = event.clientY > rect.top + rect.height / 2

    if (insertAfter) {
      targetRow.after(this.draggedElement)
    } else {
      targetRow.before(this.draggedElement)
    }
  }

  async dragEnd() {
    if (!this.draggedElement) return

    this.draggedElement.classList.remove("opacity-50")
    this.draggedElement = null

    const fieldIds = Array.from(
      this.element.querySelectorAll("[data-field-id]")
    ).map(row => row.dataset.fieldId)

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    if (!csrfToken) {
      alert("Security token missing. Please reload the page.")
      window.location.reload()
      return
    }

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "text/plain"
        },
        body: JSON.stringify({ field_ids: fieldIds }),
        credentials: "same-origin"
      })

      if (!response.ok) {
        throw new Error("Could not save field order")
      }
    } catch (error) {
      console.error(error)
      alert("Could not save the new field order. The page will reload.")
      window.location.reload()
    }
  }
}
