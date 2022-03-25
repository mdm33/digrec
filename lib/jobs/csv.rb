# encoding: UTF-8
#--
#
# Copyright 2022 Morgan Macleod
#
# This file is part of the DiGreC web application.
#
# The DiGreC web application is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# The DiGreC web application is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the DiGreC web application.  If not, see
# <http://www.gnu.org/licenses/>.
#
#++

module Proiel
  module Jobs
    class CSV < Job
      def initialize(export_directory, logger = Rails.logger, zip = false)
        raise ArgumentError, "no such directory #{@export_directory}" unless export_directory and File::directory?(export_directory)

        super(logger)

        @export_directory = export_directory

        @zip = zip
      end

      def run_once!
        @logger.info { "#{self.class}: Exporting sources.csv" }
        srcfile = File.open(File.join(@export_directory, "sources.csv"), 'w')
        srcfile.puts('"id","title","citation_part","language_tag","author","code","electronic_text_original_url","printed_text_date"')
        Source.all.each do |src|
          dt=src.send('printed_text_date')
          unless dt.nil?
            dt='"'+dt+'"'
          end
          srcfile.puts [src.id, '"'+src.title+'"', '"'+src.citation_part+'"', '"'+src.language_tag+'"', '"'+src.author+'"', '"'+src.human_readable_id+'"', '"'+src.send('electronic_text_original_url')+'"', dt].join(',')
        end
        @logger.info { "#{self.class}: Exporting slashes.csv" }
        slfile = File.open(File.join(@export_directory, "slashes.csv"), 'w')
        slfile.puts('"id","slasher_id","slashee_id","relation_tag"')
        SlashEdge.all.each do |slash|
          slfile.puts [slash.id, slash.slasher_id, slash.slashee_id, '"'+slash.relation_tag+'"'].join(',')
        end
        @logger.info { "#{self.class}: Exporting tokens.csv" }
        cp=''
        ActiveRecord::Base.connection.execute 'CREATE OR REPLACE ALGORITHM = TEMPTABLE VIEW token_counts AS SELECT tokens.sentence_id, Max(tokens.token_number) AS max_token FROM tokens GROUP BY sentence_id;'
		result = ActiveRecord::Base.connection.exec_query('SELECT tokens.id, source_divisions.source_id, source_divisions.position AS source_division, sentences.sentence_number, tokens.token_number, Concat(sources.citation_part," ",tokens.citation_part) AS citation, If(tokens.empty_token_sort Is Null,"",tokens.empty_token_sort) AS empty_token_sort, Concat(If(tokens.token_number=0 And sentences.presentation_before Is Not Null,sentences.presentation_before,""),If(tokens.presentation_before Is Null,"",tokens.presentation_before)) AS presentation_before, If(tokens.form Is Null,"",tokens.form) AS form, Concat(If(tokens.presentation_after Is Null,"",tokens.presentation_after),If(tokens.token_number=token_counts.max_token And sentences.presentation_after Is Not Null,sentences.presentation_after,"")) AS presentation_after, If(lemmata.lemma Is Null,"",lemmata.lemma) AS lemma, If(lemmata.part_of_speech_tag Is Null,"",lemmata.part_of_speech_tag) AS part_of_speech_tag, If(tokens.morphology_tag Is Null,"",tokens.morphology_tag) AS morphology_tag, tokens.head_id, If(tokens.relation_tag Is Null,"",tokens.relation_tag) AS relation_tag, If(semantic_tags.semantic_attribute_value_id Is Null,"",If(semantic_tags.semantic_attribute_value_id=1,"a",If(semantic_tags.semantic_attribute_value_id=2,"i","p"))) AS animacy FROM (((((tokens INNER JOIN sentences ON tokens.sentence_id = sentences.id) INNER JOIN source_divisions ON sentences.source_division_id = source_divisions.id) INNER JOIN sources ON source_divisions.source_id = sources.id) INNER JOIN token_counts ON tokens.sentence_id = token_counts.sentence_id) LEFT JOIN lemmata ON tokens.lemma_id = lemmata.id) LEFT JOIN semantic_tags ON tokens.id = semantic_tags.taggable_id;')
        tfile = File.open(File.join(@export_directory, "tokens.csv"), 'w')
        tfile.puts('"id","source_id","source_division","sentence_number","token_number","citation","empty_token_sort","presentation_before","form","presentation_after","lemma","part_of_speech_tag","morphology_tag","head_id","relation_tag","animacy"')
        result.each do |t|
          unless t['citation'].nil?
            cp=t['citation']
          end
          tfile.puts [t['id'], t['source_id'], t['source_division'], t['sentence_number'], t['token_number'], '"'+cp+'"', '"'+t['empty_token_sort']+'"', '"'+t['presentation_before']+'"', '"'+t['form']+'"', '"'+t['presentation_after']+'"', '"'+t['lemma']+'"', '"'+t['part_of_speech_tag']+'"', '"'+t['morphology_tag']+'"', t['head_id'], '"'+t['relation_tag']+'"', '"'+t['animacy']+'"'].join(',')
        end
      end
    end
  end
end
