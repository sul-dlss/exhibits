# frozen_string_literal: true

namespace :factory_bot do
  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    if Rails.env.test?
      DatabaseCleaner.cleaning do
        factories_to_lint = FactoryBot.factories.reject do |factory|
          factory.name =~ /^job_tracker/
        end

        FactoryBot.lint factories_to_lint
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      exit $CHILD_STATUS.exitstatus
    end
  end
end
