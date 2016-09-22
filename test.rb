require_relative 'config/environment'

DorHarvester.new(druid_list: 'gh795jd5965', exhibit: Spotlight::Exhibit.find('testcb')).reindex
