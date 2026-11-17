// Configure your import map in config/importmap.rb.
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

// Initialize Bootstrap tooltips
function initializeTooltips() {
  document
    .querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach((element) => {
      bootstrap.Tooltip.getOrCreateInstance(element)
    })
}

// Initialize tooltips whenever a Turbo page loads
document.addEventListener("turbo:load", initializeTooltips)

// Dispose tooltips before Turbo caches the page
document.addEventListener("turbo:before-cache", () => {
  document
    .querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach((element) => {
      bootstrap.Tooltip.getInstance(element)?.dispose()
    })
})
