// app/javascript/controllers/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "spinner"]

  onSubmitStart() {
    // Disable the submit button
    this.submitTarget.disabled = true

    // Show the spinner
    this.spinnerTarget.classList.remove("hidden")

    // Replace empty state with loading state
    const frame = document.getElementById("email-preview")
    if (frame) {
      frame.innerHTML = this.loadingStateHTML()
    }
  }

  onSubmitEnd() {
    // Re-enable the submit button
    this.submitTarget.disabled = false

    // Hide the spinner
    this.spinnerTarget.classList.add("hidden")
  }

  loadingStateHTML() {
    return `
      <div class="flex flex-col items-center justify-center h-full p-8 text-center bg-gray-50 rounded-lg">
        <svg class="animate-spin w-12 h-12 text-blue-600 mb-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <h3 class="text-lg font-medium text-gray-900">Generating your email</h3>
        <p class="mt-1 text-sm text-gray-500">This may take a few seconds...</p>
      </div>
    `
  }
}
