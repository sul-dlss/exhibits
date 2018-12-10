Settings.revision = File.read("#{Rails.root}/REVISION").chomp if File.exists?("#{Rails.root}/REVISION")
