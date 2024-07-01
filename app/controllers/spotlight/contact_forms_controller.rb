# frozen_string_literal: true

# This unpleasantness allows us to include the upstream controller before overriding it
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/controllers/spotlight/contact_forms_controller')

# Override the upstream controller to add recaptcha
module Spotlight
  ##
  # Controller for routing exhibit feedback from users
  class ContactFormsController
    def create
      return render 'new' unless @contact_form.valid?

      if verify_recaptcha(action: 'feedback')
        send_feedback
      else
        report_failure
      end
    end

    private

    def send_feedback
      ContactMailer.report_problem(@contact_form).deliver_now
      redirect_back fallback_location: spotlight.new_exhibit_contact_form_path(current_exhibit),
                    notice: t(:'helpers.submit.contact_form.created')
    end

    def report_failure
      redirect_back fallback_location: spotlight.new_exhibit_contact_form_path(current_exhibit),
                    alert: t(:'helpers.submit.contact_form.error')
    end
  end
end
