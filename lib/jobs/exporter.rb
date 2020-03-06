# encoding: UTF-8
#--
#
# Copyright 2007-2013 University of Oslo
# Copyright 2007-2016 Marius L. Jøhndal
# New material copyright 2019 Morgan Macleod
#
# This file is part of the PROIEL web application.
#
# The PROIEL web application is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# The PROIEL web application is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the PROIEL web application.  If not, see
# <http://www.gnu.org/licenses/>.
#
#++

module Proiel
  module Jobs
    class Exporter < Job
      # ==== Options
      # * <tt>:id</tt> - If set, only exports the source with the given ID. If not set,
      # all sources are expored.
      # * <tt>:source_division</tt> - If set to a regular expression, only
      # exports source divisions whose titles match the regular expression.
      # * <tt>:semantic_tags</tt> - If true, will also export semantic tags.
      def initialize(export_directory, logger = Rails.logger, options = {})
        raise ArgumentError, "no such directory #{@export_directory}" unless export_directory and File::directory?(export_directory)

        super(logger)

        @export_directory = export_directory

        @options = options
        @options.symbolize_keys!
        @options.reverse_merge! semantic_tags: false
      end

      def run_once!
        options = {}
        options[:sem_tags] = true if @options[:semantic_tags]

        # Find sources and iterate them
        sources = @options[:id] ? Source.find_all_by_id(@options[:id]) : Source.all

        #sources.each do |source|
          file_name = File.join(@export_directory, @options[:id] ? "#{sources[0].human_readable_id}.xml" : "export.xml")

          if @options[:id] && @options[:source_division]
            options[:source_division] = sources[0].source_divisions.select { |sd| sd.title =~ Regexp.new(@options[:source_division]) }.map(&:id)
          end

          begin
            if @options[:id]
              @logger.info { "#{self.class}: Exporting source ID #{sources[0].id} as #{file_name}" }
            else
              @logger.info { "#{self.class}: Exporting all sources as #{file_name}" }
            end
            PROIELXMLExporter.new(sources, options).write(file_name)
          rescue Exception => e
            @logger.error { "#{self.class}: Error exporting text #{sources[0].human_readable_id}: #{e}\n" + e.backtrace.join("\n") }
          end
        #end
      end
    end
  end
end
