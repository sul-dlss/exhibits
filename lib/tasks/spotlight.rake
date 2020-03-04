# frozen_string_literal: true

namespace :spotlight do
  desc 'Update to the latest blacklight + spotlight dependencies'
  task upgrade: :environment do
    Bundler.with_clean_env do
      system 'bundle update blacklight blacklight-spotlight spotlight-dor-resources'
      system 'bundle exec rake blacklight:install:migrations'
      system 'bundle exec rake spotlight:install:migrations'
      system 'bundle exec rake db:migrate'
    end
  end
  desc 'Remove empty anchors'
  task remediate_anchors: :environment do
    url_regex = %r{<a href="(https?|mailto:)[\S]+">(<br>)?<\/a>}
    Spotlight::Page.find_each.select do |p|
      p.content.any? { |c| c.text.to_s.match? url_regex }
    end.each do |p|
      dup = p.content
      p.content.each_with_index do |c, i|
        dup[i].text = c.text.to_s.gsub(url_regex, '') if c.text.to_s.match? url_regex
      end
      p.content = dup
      p.save
    end
  end
end
