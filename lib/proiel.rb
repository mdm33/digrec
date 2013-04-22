# encoding: UTF-8
#--
#
# Copyright 2013 University of Oslo
# Copyright 2013 Marius L. Jøhndal
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

autoload :SourceExporter, 'exporter/source_exporter'
autoload :XMLSourceExporter, 'exporter/xml_source_exporter'
autoload :PROIELXMLExporter, 'exporter/proiel_xml_exporter'
autoload :TextExporter, 'exporter/text_exporter'
autoload :CoNLLExporter, 'exporter/conll_exporter'
autoload :TigerXMLExporter, 'exporter/tiger_xml_exporter'
autoload :Tiger2Exporter, 'exporter/tiger2_exporter'
autoload :JSONExporter, 'exporter/json_exporter'

autoload :SourceImporter, 'importer/source_importer'
autoload :XMLSourceImporter, 'importer/xml_source_importer'
autoload :PROIELXMLImporter, 'importer/proiel_xml_importer'
autoload :JSONImporter, 'importer/json_importer'

autoload :Metadata, 'metadata'

module Proiel
  autoload :TokenAnnotationValidator, 'annotation_validator'
  autoload :SentenceAnnotationValidator, 'annotation_validator'
end

require 'presentation'
require 'ordering'
require 'blankable'

require 'proiel/dependency_graph'
require 'proiel/tagger'

require 'yaml'

module PROIEL
  INFERENCES = YAML::load_file(File.join(Rails.root.join('lib', 'proiel', 'inferences.yml'))).freeze
end
