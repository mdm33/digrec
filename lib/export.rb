#!/usr/bin/env ruby
#
# export.rb - Export functions for PROIEL sources
#
# Written by Marius L. Jøhndal, 2007, 2008.
#
require 'builder'
require 'metadata'

# Monkeypatch builder with a less obtuse version of XML escaping
class String
  def to_xs
    self.gsub(/'/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')
  end
end

# Abstract source exporter.
class SourceExport
  # Creates a new exporter that exports the source +source+ 
  #
  # ==== Options
  # reviewed_only:: Only include reviewed sentences. Default: +false+.
  def initialize(source, options = {})
    options.assert_valid_keys(:reviewed_only)
    options.reverse_merge! :reviewed_only => false

    @source = source
    @metadata = source.metadata
    @options = options
  end

  # Writes the exported data to a file or an IO object.
  def write(file)
    case file
    when String
      File.open(file, 'w') { |f| do_export(f) }
    else
      do_export(file)
    end
  end


  # Returns the sentences to be exported by the exporter.
  def filtered_sentences(source_division = nil)
    if source_division
      if @options[:reviewed_only]
        source_division.sentences.reviewed
      else
        source_division.sentences
      end
    else
      @source.source_divisions.map { |d| filtered_sentences(d) }.flatten
    end
  end

  protected

  # Returns the public identifier for the source.
  def identifier
    @source.code
  end
end

# Source exporter for the PROIEL XML format.
class PROIELXMLExport < SourceExport
  protected

  def do_export(file)
    builder = Builder::XmlMarkup.new(:target => file, :indent => 2)
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.text(:id => identifier, :lang => @source.language.iso_code) do
      builder.metadata { write_metadata(builder) }
      @source.source_divisions.each do |source_division|
        builder.div(:type => 'book', :name => source_division.fields.match(/book=([A-Z]+)/)[1]) do
          builder.div(:type => 'chapter', :name => source_division.fields.match(/chapter=(\d+)/)[1]) do
            write_source_division(builder, source_division)
          end
        end
      end
    end
  end

  private

  def write_metadata(builder)
    @metadata.write(builder)
  end

  def write_source_division(builder, source_division)
    filtered_sentences(source_division).each do |sentence|
      builder.sentence { write_sentence(builder, sentence) }
    end
  end

  VERBATIM_TOKEN_ATTRIBUTES = %w(morphtag presentation_form form presentation_span nospacing contraction
    emendation abbreviation capitalisation verse relation empty_token_sort foreign_ids)

  def write_sentence(builder, sentence)
    sentence.tokens.each do |token|
      attributes = { :id => token.id }
      attributes[:head] = token.head_id if token.head
      attributes[:lemma] = token.morph_lemma_tag.lemma if token.morph_lemma_tag
      attributes[:sort] = token.sort.to_s.gsub('_', '-')

      VERBATIM_TOKEN_ATTRIBUTES.each do |a|
        value = token.send(a.to_sym)
        attributes[a.gsub('_', '-')] = value unless value.blank?
      end

      unless token.slashees.empty? # this extra test avoids <token></token> style XML
        builder.token attributes do
          builder.slashes do
            token.slash_out_edges.each do |slash_out_edge|
              builder.slash :target => slash_out_edge.slashee_id, :label => slash_out_edge.slash_edge_interpretation.tag
            end
          end
        end
      else
        builder.token attributes
      end
    end
  end
end

# Source exporter for the TigerXML format
# (http://www.ims.uni-stuttgart.de/projekte/TIGER/TIGERSearch/doc/html/TigerXML.html)
# in the variant used by VISL under the name `TIGER dependency format'
# (http://beta.visl.sdu.dk/treebanks.html#TIGER_dependency_format).
class TigerXMLExport < SourceExport
  protected

  def do_export(file)
    builder = Builder::XmlMarkup.new(:target => file, :indent => 2)
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.corpus(:id => self.identifier) do
      builder.meta { write_meta(builder) } 
      builder.head { write_head(builder) }
      builder.body { write_body(builder) }
    end
  end

  private

  def write_meta(builder)
    builder.name(@source.title)
  end

  def write_head(builder)
    builder.annotation do
      builder.feature(:name => 'form', :domain => 'FREC')
      builder.feature(:name => 'morphtag', :domain => 'FREC')
      builder.feature(:name => 'lemma', :domain => 'FREC')
      builder.edgelabel do
        builder.value(:name => '--')
        PROIEL::RELATIONS.each_pair do |key, value|
          builder.comment! value.description
          builder.value(:name => key)
        end
      end
      builder.secedgelabel do
        builder.value(:name => '*')
      end
    end
  end

  def token_attrs(s, t)
    attrs = { :form => t.form || '' }

    if s.has_morphological_annotation? and t.is_morphtaggable?
      attrs.merge!({ :morphtag => t.morph_lemma_tag.morphtag.to_s, 
                     :lemma => t.morph_lemma_tag.lemma.to_s })
    else
      attrs.merge!({ :morphtag => '',
                     :lemma => '' })
    end
    attrs
  end

  def write_body(builder)
    filtered_sentences.each do |s|
      builder.s(:id => "s#{s.id}") do
        root_node_id = "s#{s.id}_root"

        builder.graph(:root => root_node_id) do
          builder.terminals do
            s.morphtaggable_tokens.each do |t|
              builder.t(token_attrs(s, t).merge({ :id => "w#{t.id}"}))
            end
          end

          if s.has_dependency_annotation?
            builder.nonterminals do
              # Emit the empty root node
              builder.nt(:id => root_node_id, :form => '', :morphtag => '', :lemma => '') do
                s.dependency_tokens.reject(&:head).each do |t|
                  builder.edge(:idref => "p#{t.id}", :label => t.relation)
                end
              end

              # Do the actual nodes
              s.dependency_tokens.each do |t|
                builder.nt(token_attrs(s, t).merge({ :id => "p#{t.id}"})) do
                  # Add an edge between this node and the correspoding terminal node unless
                  # this is not a morphtaggable node.
                  builder.edge(:idref => "w#{t.id}", :label => '--') if t.is_morphtaggable?

                  # Add dependency edges, primary and secondary.
                  t.dependents.each { |d| builder.edge(:idref => "p#{d.id}", :label => d.relation) }
                  t.slashers.each { |d| builder.secedge(:idref => "p#{d.id}", :label => '*') }
                end
              end
            end
          end
        end
      end
    end
  end
end

# Source exporter for the MaltXML format
# (http://w3.msi.vxu.se/~nivre/research/MaltXML.html).
# Note that this exporter does not support secondary edges.
class MaltXMLExport < SourceExport
  protected

  def do_export(file)
    builder = Builder::XmlMarkup.new(:target => file, :indent => 2)
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.treebank(:id => self.identifier,
                     'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                     'xmlns:treebank' => "http://www.msi.vxu.se/~rics/treebank",
                     'xsi:schemaLocation' => "http://www.msi.vxu.se/~rics/treebank treebank.xsd") do 
      builder.head do
        builder.annotation do
          builder.attribute(:name => "head")
          builder.attribute(:name => "deprel") do
            PROIEL::RELATIONS.each_pair do |key, value|
              builder.comment! value.description
              builder.value(:name => key)
            end
          end
          builder.attribute(:name => "form")
          builder.attribute(:name => "morphtag")
          builder.attribute(:name => "lemma")
        end
      end

      builder.body do
        filtered_sentences.each do |s|
          builder.sentence(:id => s.id) do
            # Create a mapping from PROIEL token IDs to one-based, sentence
            # internal IDs. (I don't like reusing the same id attribute values in 
            # XML in this manner, but what can one do...) The ID 1 is reserved
            # for an empty root node to be added later, so we start the mapping at
            # ID 2.
            ids = s.dependency_tokens.collect(&:id)
            local_token_ids = Hash[*ids.zip((2..(ids.length + 1)).to_a).flatten]

            # Add another one to function as a root node. This is necessary
            # since MaltXML requires there to be a single `root word' with 
            # its deprel attribute set to `ROOT'. We also need to emit this
            # word in the XML file.
            local_token_ids[nil] = 1
            builder.word({ :id => 1, :head => 0, :deprel => 'ROOT' })

            s.dependency_tokens.each do |t|
              attrs = { :id => local_token_ids[t.id]}
              attrs.merge!({ :form => t.form }) if t.form

              if s.has_dependency_annotation?
                attrs.merge!({ :head => local_token_ids[t.head_id] })
                attrs.merge!({ :deprel => t.relation })
              end

              if s.has_morphological_annotation? and t.is_morphtaggable?
                attrs.merge!({ :morphtag => t.morph_lemma_tag.morphtag.to_s, 
                               :lemma => t.morph_lemma_tag.lemma.to_s })
              end

              builder.word(attrs)
            end
          end
        end
      end
    end
  end
end
