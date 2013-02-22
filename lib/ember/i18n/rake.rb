namespace :ember do
  namespace :i18n do
    desc "Copy i18n.js and configuration file"
    task :setup => :environment do
      Ember::I18n.setup!
    end

    desc "Export the messages files"
    task :export => :environment do
      Ember::I18n.export!
    end

    desc "Update the JavaScript library"
    task :update => :environment do
      Ember::I18n.update!
    end
  end
end

