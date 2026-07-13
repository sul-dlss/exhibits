# frozen_string_literal: true

ActiveRecord::Migration.suppress_messages do
  ActsAsTaggableOn.force_binary_collation = true
end
