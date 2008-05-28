#TODO
USER_NAME='mlj'

DEFAULT_EXPORT_DIRECTORY = File.join(RAILS_ROOT, 'public', 'exports')

namespace :proiel do
  task(:myenvironment => :environment) do
    require 'jobs'
  end

  desc "Validate PROIEL database"
  task(:validator => :myenvironment) do
    require 'tools/db_validator'

    v = Validator.new(false)
    v.execute!(USER_NAME)
  end

  desc "Force manual morphological rules. SOURCES=source_identifier[,..]"
  task(:manual_tagger => :myenvironment) do
    require 'tools/manual_tagger'
  
    raise "Source identifiers required" unless ENV['SOURCES']

    source_ids = ENV['SOURCES'].split(',').collect { |s| Source.find_by_code(s) }

    v = ManualTagger.new(source_ids)
    v.execute!(USER_NAME)
  end

  desc "Import a PROIEL source text. Options: FILE=data_file BOOK=book_filter" 
  task(:import => :environment) do
    require 'import'

    raise "Filename required" unless ENV['FILE']
    e = ENV['BOOK'] ? PROIELXMLImport.new(:book_filter => ENV['BOOK']) : PROIELXMLImport.new
    e.read(ENV['FILE'])
  end

  desc "Export a PROIEL source text. Options: ID=source_identifier"
  task(:export => :environment) do
    require 'export'

    source = Source.find_by_code(ENV['ID'])
    raise "Source not found" unless source
    e = PROIELXMLExport.new(source)
    e.write("#{source.code}.xml")
  end

  namespace :export do
    namespace :all do
      require 'export'

      desc "Export all PROIEL source texts with all publicly available data."
      task(:public => :myenvironment) do
        Dir::mkdir(DEFAULT_EXPORT_DIRECTORY) unless File::directory?(DEFAULT_EXPORT_DIRECTORY)
        File::copy(File.join(RAILS_ROOT, 'data', 'text.xsd'), 
                   File.join(DEFAULT_EXPORT_DIRECTORY, 'text.xsd'))
        File::copy(File.join(RAILS_ROOT, 'lib', 'proiel', 'morphology.xml'), 
                   File.join(DEFAULT_EXPORT_DIRECTORY, 'morphology.xml'))
        File::copy(File.join(RAILS_ROOT, 'lib', 'proiel', 'relations.xml'), 
                   File.join(DEFAULT_EXPORT_DIRECTORY, 'relations.xml'))
        Source.find(:all).each do |source|
          e = PROIELXMLExport.new(source, :reviewed_only => true)
          e.write(File.join(DEFAULT_EXPORT_DIRECTORY, "#{source.code}.xml"))

          e = TigerXMLExport.new(source, :reviewed_only => true)
          e.write(File.join(DEFAULT_EXPORT_DIRECTORY, "#{source.code}-tiger.xml"))

          e = MaltXMLExport.new(source, :reviewed_only => true)
          e.write(File.join(DEFAULT_EXPORT_DIRECTORY, "#{source.code}-malt.xml"))
        end
      end
    end
  end
end
