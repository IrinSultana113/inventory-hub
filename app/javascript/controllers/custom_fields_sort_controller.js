
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

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "text/plain"
        },
        body: JSON.stringify({ field_ids: fieldIds }),
        credentials: "same-origin"
      })

      if (!response.ok) {
        throw new Error("Could not save field order")
      }
    } catch (error) {
      alert("Could not save the new field order. Please reload the page.")
      console.error(error)
    }
  }
}
