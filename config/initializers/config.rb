require 'ostruct'

# Local configuration
class ApplicationConfig
  include Singleton

  def initialize
    @file_name = File.join(RAILS_ROOT, 'config', 'config.yml')
    if File.exist?(@file_name)
      @config = OpenStruct.new(YAML.load_file(@file_name))
    else
      raise "#{@file_name} missing"
    end
  end

  def presentation_as_html_stylesheet
    @presentation_as_html_stylesheet ||= XSLT::Stylesheet.new(XML::Document.file(@config.presentation_as_html_stylesheet))
  end

  def presentation_as_text_stylesheet
    @presentation_as_text_stylesheet ||= XSLT::Stylesheet.new(XML::Document.file(@config.presentation_as_text_stylesheet))
  end

  def presentation_as_reference_stylesheet
    @presentation_as_reference_stylesheet ||= XSLT::Stylesheet.new(XML::Document.file(@config.presentation_as_reference_stylesheet))
  end
end

APPLICATION_CONFIG = ApplicationConfig.instance