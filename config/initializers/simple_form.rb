# frozen_string_literal: true

SimpleForm.setup do |config|
  config.wrappers :custom, tag: 'div', class: 'form-control' do |input|
    input.use :html5
    input.use :placeholder
    input.optional :maxlength
    input.optional :minlength
    input.optional :pattern
    input.optional :min_max
    input.optional :readonly
    input.use :label, class: 'label mt-2'
    input.use :input, class: 'input input-bordered input-primary', autocomplete: 'off', spellcheck: 'off', 'data-gramm': false

    input.use :error, wrap_with: { tag: 'div', class: 'text-xs mt-2 text-error' }
    input.use :hint, wrap_with: { tag: :span, class: 'text-xs mt-2 text-info' }
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'form-control' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper :label_tag, tag: 'label', class: 'cursor-pointer label mt-2' do |ba|
      ba.use :label_text, wrap_with: { tag: 'span', class: 'label-text' }
      ba.use :input, class: 'checkbox input-bordered input-primary ml-2'
    end

    b.use :error, wrap_with: { tag: 'div', class: 'text-xs mt-1 text-error' }
    b.use :hint, wrap_with: { tag: :span, class: 'text-xs mt-1 text-info' }
  end

  config.default_form_class = 'form'
  config.label_text = ->(label, required, explicit_label) { "#{label} #{required ? required : '(optional)'}" }
  config.default_wrapper = :custom
  config.boolean_style = :inline
  config.button_class = 'btn btn-primary'
  config.error_notification_tag = :div
  config.error_notification_class = 'alert alert-error'
  config.browser_validations = false
  config.boolean_label_class = 'checkbox'
  config.i18n_scope = 'form'
  config.generate_additional_classes_for = []

  config.wrapper_mappings = {
    boolean: :horizontal_boolean
  }
end
