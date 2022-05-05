# frozen_string_literal: true

SimpleForm.setup do |config|
  config.wrappers :custom, tag: 'div', class: 'form-control', error_class: 'input-error' do |input|
    input.use :html5
    input.use :placeholder
    input.optional :maxlength
    input.optional :minlength
    input.optional :pattern
    input.optional :min_max
    input.optional :readonly
    input.use :label, class: 'label text-sm mt-2'
    input.use :input, class: 'input input-bordered input-md', autocomplete: 'off', spellcheck: 'off'

    input.use :error, wrap_with: { tag: 'div', class: 'input-error-message text-xs mt-2 text-error' }
    input.use :hint, wrap_with: { tag: :div, class: 'input-hint-message text-xs mt-2 text-info' }
  end

  config.wrappers :input_group, tag: 'div', class: 'form-control', error_class: 'input-error' do |wrapper|
    wrapper.use :html5
    wrapper.use :placeholder
    wrapper.optional :maxlength
    wrapper.optional :minlength
    wrapper.optional :pattern
    wrapper.optional :min_max
    wrapper.optional :readonly

    wrapper.wrapper :label_tag, tag: 'label', class: 'input-group' do |ba|
      ba.use :label_text, wrap_with: { tag: 'span', class: 'label-text text-sm' }
      ba.use :input, class: 'input input-bordered input-md', autocomplete: 'off', spellcheck: 'off'
    end

    wrapper.use :error, wrap_with: { tag: 'div', class: 'input-error-message text-xs mt-2 text-error' }
    wrapper.use :hint, wrap_with: { tag: :div, class: 'input-hint-message text-xs mt-2 text-info' }
  end

  config.wrappers :file, tag: 'div', class: 'form-control', error_class: 'input-error' do |input|
    input.use :html5
    input.use :placeholder
    input.optional :maxlength
    input.optional :minlength
    input.optional :pattern
    input.optional :min_max
    input.optional :readonly
    input.use :label, class: 'label text-sm mt-2'
    input.use :input, autocomplete: 'off', spellcheck: 'off'

    input.use :error, wrap_with: { tag: 'div', class: 'input-error-message text-xs mt-2 text-error' }
    input.use :hint, wrap_with: { tag: :div, class: 'input-hint-message text-xs mt-2 text-info' }
  end

  config.wrappers :textarea, tag: 'div', class: 'form-control', error_class: 'textarea-error' do |input|
    input.use :html5
    input.use :placeholder
    input.optional :maxlength
    input.optional :minlength
    input.optional :pattern
    input.optional :min_max
    input.optional :readonly
    input.use :label, class: 'label text-sm mt-2'
    input.use :input, class: 'textarea textarea-bordered textarea-md', autocomplete: 'off', spellcheck: 'off'

    input.use :error, wrap_with: { tag: 'div', class: 'input-error-message text-xs mt-2 text-error' }
    input.use :hint, wrap_with: { tag: :div, class: 'input-hint-message text-xs mt-2 text-info' }
  end

  config.wrappers :select, tag: 'div', class: 'form-control', error_class: 'select-error' do |input|
    input.use :html5
    input.use :placeholder
    input.optional :maxlength
    input.optional :minlength
    input.optional :pattern
    input.optional :min_max
    input.optional :readonly
    input.use :label, class: 'label text-sm mt-2'
    input.use :input, class: 'select select-bordered select-md', autocomplete: 'off', spellcheck: 'off'

    input.use :error, wrap_with: { tag: 'div', class: 'input-error-message text-xs mt-2 text-error' }
    input.use :hint, wrap_with: { tag: :div, class: 'input-hint-message text-xs mt-2 text-info' }
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'form-control' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper :label_tag, tag: 'label', class: 'cursor-pointer label mt-2' do |ba|
      ba.use :label_text, wrap_with: { tag: 'span', class: 'label-text text-sm' }
      ba.use :input, class: 'checkbox checkbox-bordered checkbox-md ml-2'
    end

    b.use :error, wrap_with: { tag: 'div', class: 'input-error-message text-xs mt-1 text-error' }
    b.use :hint, wrap_with: { tag: :div, class: 'input-hint-message text-xs mt-1 text-info' }
  end

  config.default_form_class = 'form'
  config.default_wrapper = :custom
  config.label_text = ->(label, required, explicit_label) { "#{label} #{required ? required : '(optional)'}" }
  config.boolean_style = :inline
  config.error_notification_tag = :div
  config.error_notification_class = 'alert alert-error'
  config.browser_validations = false
  config.boolean_label_class = 'checkbox'
  config.i18n_scope = 'form'
  config.button_class = 'btn btn-sm'
  config.generate_additional_classes_for = []

  config.wrapper_mappings = {
    boolean: :horizontal_boolean,
    text: :textarea,
    select: :select,
    file: :file
  }
end
