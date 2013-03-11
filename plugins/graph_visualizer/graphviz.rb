#--
#
# graphviz.rb - Graph visualization functions using graphviz
#
# Copyright 2007, 2008, 2009, 2010, 2011, 2012, 2013 University of Oslo
# Copyright 2007, 2008, 2009, 2010, 2011, 2012, 2013 Marius L. Jøhndal
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

require 'plugin.rb'
require 'erb'
require 'open3'

class VisualizationError < Exception
end

class GraphvizVisualizer < PROIEL::GraphVisualizer
  def initialize
    super :graphviz, 'Graphviz'
  end

  def generate(sentence, options = {})
    g = GraphvizVisualization.new(sentence)
    g.generate(options)
  end
end

class GraphvizVisualization
  SUPPORTED_FORMATS = [:png, :svg, :dot]

  def initialize(sentence)
    @sentence = sentence
    @tokens = sentence.tokens
  end

  # Generates a graph using dot.
  #
  # ==== Options
  # format::   Image format. Default is +:png+.
  # mode::     Chooses visualization method. Possible values are +:packed+
  #            and +:linearized+. Default is +:packed+.
  def generate(options = {})
    options[:format] ||= :png
    options[:mode] ||= :packed

    raise ArgumentError, "invalid format" unless SUPPORTED_FORMATS.include?(options[:format])

    template_file = File.join(File.dirname(__FILE__), 'graphviz', "#{options[:mode]}.dot.erb")
    content = File.read(template_file)
    template = ERB.new(content)
    template.filename = template_file

    case options[:format]
    when :dot
      template.result(binding)
    else
      result = nil
      errors = nil

      Open3.popen3("dot -T#{options[:format]}") do |dot, img, err|
        dot.write template.result(binding)
        dot.close

        result = img.read
        errors = err.read
      end

      raise VisualizationError, "graphviz exited: #{errors}" unless errors.blank?

      result
    end
  end

  protected

  # Creates a node with identifier +identifier+.
  def node(identifier, label = '', options = {})
    attrs = { :label => label.gsub('"', '\\"') }.merge(options)
    "#{identifier} [#{join_attributes(attrs)}];"
  end

  # Creates an edge from identifier +identifier1+ to identifier
  # +identifier2+.
  def edge(identifier1, identifier2, label = '', options = {})
    attrs = { :label => label.gsub('"', '\\"') }.merge(options)
    "#{identifier1} -> #{identifier2} [#{join_attributes(attrs)}];"
  end

  def join_attributes(attrs)
    attrs.collect { |attr, value| "#{attr}=\"#{value}\"" }.join(',')
  end
end

PROIEL::register_plugin GraphvizVisualizer
