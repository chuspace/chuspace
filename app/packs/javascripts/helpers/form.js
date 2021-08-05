// @flow

import { Controller } from 'stimulus'
import capitalize from 'lodash/capitalize'
type Error = {
  field: string,
  errors: string
}

const withForm = (BaseForm: Controller) =>
  class extends BaseForm {
    static targets = ['form', 'formSuccess', ...BaseForm.inputs, ...BaseForm.errors]

    onFormSubmit(event: window.CustomEvent) {
      const [data] = event.detail

      if (data.errors && data.errors.length > 0) {
        this.resetErrors()
        this.setFormErrors(data.errors)
        return
      }

      this.setSuccessMessage(data.success)
      this.toggleSuccess()

      setTimeout(() => {
        this.reset()
      }, 2000)
    }

    toggleSuccess = () => this.formTarget.classList.add('hidden')

    setFormErrors = (errors: $ReadOnlyArray<Error>) =>
      errors.forEach(error => {
        const target = this[`input${capitalize(error.field)}ErrorTarget`]
        if (target) target.innerHTML = error.errors
      })

    setSuccessMessage = (message: string) => {
      this.formSuccessTarget.innerHTML = message
    }

    reset = () => {
      this.resetForm()
      this.resetErrors()
      this.setSuccessMessage('')
      this.formTarget.classList.remove('hidden')
    }

    resetForm = () =>
      BaseForm.inputs.forEach(targetKey => {
        const target = this[`${targetKey}Target`]
        target.value = ''
      })

    resetErrors = () =>
      BaseForm.errors.forEach(targetKey => {
        const target = this[`${targetKey}Target`]
        target.innerHTML = ''
      })
  }

export default withForm
