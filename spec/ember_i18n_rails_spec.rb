require "spec_helper"

if File.basename(Rails.root) != "tmp"
  abort <<-TXT
\e[31;5m
WARNING: That will remove your project!
Please go to #{File.expand_path(File.dirname(__FILE__) + "/..")} and run `rake spec`\e[0m
TXT
end

describe Ember::I18n do
  before do
    # Remove temporary directory if already present
    FileUtils.rm_r(Rails.root) if File.exist?(Rails.root)

    # Create temporary directory to test the files generation
    %w( config public/javascripts ).each do |path|
      FileUtils.mkdir_p Rails.root.join(path)
    end
  end

  after do
    # Remove temporary directory
    FileUtils.rm_r(Rails.root)
  end

  it "copies JavaScript library" do
    path = Rails.root.join("public/javascripts/ember-i18n.js")

    File.should_not be_file(path)
    Ember::I18n.setup!
    File.should be_file(path)
  end

  it "exports messages" do
    default_locales_path = Dir[File.join('spec', 'resources', '*.yml').to_s]
    Ember::I18n.should_receive(:default_locales_path).at_least(:once).and_return(default_locales_path)
    Ember::I18n.export!
    Rails.root.join(Ember::I18n.export_dir, "translations.js").should be_file
  end

  it "updates the javascript library" do
    FakeWeb.register_uri(:get, "https://raw.github.com/jamesarosen/ember-i18n/master/lib/i18n.js", :body => "UPDATED")

    Ember::I18n.setup!
    Ember::I18n.update!
    File.read(Ember::I18n.javascript_file).should == "UPDATED"
  end

  describe "#export_dir" do
    it "detects asset pipeline support" do
      Ember::I18n.stub :has_asset_pipeline? => true
      Ember::I18n.export_dir == "vendor/assets/javascripts"
    end

    it "detects older Rails" do
      Ember::I18n.stub :has_asset_pipeline? => false
      Ember::I18n.export_dir.to_s.should == "public/javascripts"
    end
  end

  describe "#has_asset_pipeline?" do
    it "detects support" do
      Rails.stub_chain(:configuration, :assets, :enabled => true)
      Ember::I18n.should have_asset_pipeline
    end

    it "skips support" do
      Ember::I18n.should_not have_asset_pipeline
    end
  end

  private

  # Shortcut to SimplesIdeias::I18n.translations
  def translations
    Ember::I18n.translations
  end
end

