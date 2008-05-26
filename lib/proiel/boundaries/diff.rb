#!/usr/bin/env ruby
#
# diff.rb - PROIEL source boundary detection: diff method
#
# Written by Marius L. Jøhndal, 2007, 2008.
#
require 'diff/lcs'

module PROIEL
  module SentenceBoundaries
    # Runs the diff algorithm on the two sources and deduces sentence divisions by applying all
    # patches containing punctuation.
    #
    # ==== Options
    # strip_punctuation: Remove punctuation from the resulting output.
    def self.diff(a, b, writer, options = {})
      # Filter out everything we don't care about from text B.
      new_b = b.reject { |v| 
        if v[:sort] == :nonspacing_punctuation && v[:token] != '.' && v[:token] != '?' && v[:token] != ':' 
  require 'proiel/src'
          true
        else
          false
        end
      }.collect { |v| 
        x = SPLITS.fetch(v[:token], devictorianise(v[:token]))

        if x.is_a? Array
          w = v.dup
          v[:token] = x[0]
          w[:token] = x[1]
          [v, w]
        else
          v[:token] = x
          v
        end
      }.flatten

      res = PROIEL::merge_sources(a, new_b) { |source, token| token[:token].downcase }

      # Remove all additions in the merged source except the
      # punctuation (which should by now only be the punctuation
      # relevant for sentence divisions).
      final_result = res.reject { |v| v[:added] && v[:sort] != :nonspacing_punctuation }

      final_result.each do |v|
        if PROIEL::is_non_bracketing_punctuation?(v[:sort])
          # Don't track the references for this token, as it may have the wrong
          # chapter or verse numbers.
          writer.emit_word(v[:token], v.except(:deleted, :added, :token_number, :sentence_number, :chapter, :verse, :book, :token)) unless options[:strip_punctuation]
          writer.next_sentence if v[:token] == '.' || v[:token] == '?' || v[:token] == ':'
        else
          writer.track_references(v[:book], v[:chapter], v[:verse])
          writer.emit_word(v[:token], v.except(:deleted, :added, :token_number, :sentence_number, :chapter, :verse, :book, :token))
        end
      end
    end  
  end
end
  
