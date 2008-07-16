#!/usr/bin/env ruby
#
# import.rb - Import functions for PROIEL sources
#
# Written by Marius L. Jøhndal, 2007, 2008.
#
require 'proiel/src'

class SourceImport
  # Creates a new importer.
  #
  # ==== Options
  # book_filter:: If non-empty, only import books with the given code.
  # May be either a string or an array of strings.
  def initialize(options = {})
    options.assert_valid_keys(:book_filter)
    options.reverse_merge! :book_filter => []

    @book_filter = [options[:book_filter]].flatten
  end
end

class PROIELXMLImport < SourceImport
  # Reads import data. The data source +file+ may be any URI supported
  # by open-uri.
  def read(file)
    # We do not need versioning for imports, so disable it.
    Sentence.disable_auditing
    Token.disable_auditing

    import = PROIEL::XSource.new(file)
    STDOUT.puts "Importing source #{import.metadata[:id]}..."

    source = Source.find_by_code_and_language(import.metadata[:id], import.metadata[:language])

    unless source
      # Create new source and set metadata
      STDOUT.puts "Creating new source"
      source = Source.new(:code => import.metadata[:id])
      [:title, :language, :edition, :source, :editor, :url].each { |e| source[e] = import.metadata[e] }
      source.save!
    end

    book = nil
    book_id = nil
    sentence_number = nil
    sentence = nil

    args = {}
    args[:books] = @book_filter unless @book_filter.empty?

    import.read_tokens(args) do |form, attributes|
      if book != attributes[:book]
        book = attributes[:book]
        book_id = Book.find_by_code(book).id
        sentence_number = nil
        STDOUT.puts "Importing book #{book} for source #{source.code}..."
      end

      if sentence_number != attributes[:sentence_number]
        sentence_number = attributes[:sentence_number]
        sentence = source.sentences.create!(:sentence_number => sentence_number, 
                                            :book_id => book_id,
                                            :chapter => attributes[:chapter])
      end

#FIXME: this should be moved somewhere else to allow for future extensions. 
#Separate word/lemma-lists?
#            # Now hook up dictionary references,if any
#            if attributes[:references]
#              attributes[:references].split(',').each do |reference|
#                dictionary, entry = reference.split('=')
#                DictionaryReference.find_or_create_by_lemma_id_and_dictionary_identifier_and_entry_identifier(:lemma_id => lemma_id, :dictionary_identifier => dictionary,
#                                                            :entry_identifier => entry)
#              end
#            end

      # Source morphtags do not have to be valid, so we eat the tag without
      # validation.
      morphtag = attributes[:morphtag] ? PROIEL::MorphTag.new(attributes[:morphtag]).to_s : nil

      sentence.tokens.create!(
                   :token_number => attributes[:token_number], 
                   :source_morphtag => morphtag,
                   :source_lemma => attributes[:lemma],
                   :form => form, 
                   :verse => attributes[:verse], 
                   :composed_form => attributes[:composed_form],
                   :sort => attributes[:sort],
                   :foreign_ids => attributes[:foreign_ids])

      if (attributes[:relation] or attributes[:head]) and not dependency_warned
        STDERR.puts "Dependency structures cannot be imported. Ignoring."
        dependency_warned = true
      end
    end
  end
end
