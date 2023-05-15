Settings.revision = File.read("#{Rails.root}/REVISION").chomp if File.exist?("#{Rails.root}/REVISION")
