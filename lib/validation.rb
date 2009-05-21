#!/usr/bin/env ruby
#
# validation.rb - Extra (i.e. non-model) data validation
#
# Written by Marius L. Jøhndal, 2008.
#
require 'jobs'

class Validator < Task
  def initialize
    super('validator')
  end

  protected

  def run!(logger)
    check_manual_morphology(logger)
    check_lemmata(logger)
    check_orphaned_tokens(logger)
    check_changesets_and_changes(logger)
    check_morphtag_validity(logger)
  end

  private

  def check_changesets_and_changes(logger)
    failures = false

    # Check Audit first so that any fixes that lead to empty audits
    # can be handled by validation of Changeset
    changes = Audit.find(:all)
    changes.each do |change|
      change.errors.each_full { |msg| logger.error { "Audit #{change.id}: #{msg}" } } unless change.valid?

      # Remove changes from "X" to "X"
      if change.action != 'destroy'
        change.changes.each_pair do |key, values|
          old_value, new_value = values
          if old_value == new_value
            logger.warn { "Audit #{change.id}: Removing redundant diff element #{key}: #{old_value} -> #{new_value}" }
            change.changes.delete(key)
            change.save!
          end
        end
      end

      # Remove empty changes
      if change.action != 'destroy' and change.changes.empty?
        others = Audit.find(:all, :conditions => [
          "auditable_type = ? and auditable_id = ? and version > ?",
          change.auditable_type,
          change.auditable_id,
          change.version ])

        if others.length == 0
          logger.warn { "Audit #{change.id}: Removing empty diff" }
          change.destroy
        else
          logger.warn { "Audit #{change.id}: Removing empty diff and rearranging version numbers" }
          change.destroy
          others.each do |v|
            v.decrement!(:version)
          end
        end
      end
    end
  end

  def check_orphaned_tokens(logger)
    Token.find_each(:include => [ :sentence ], :conditions => [ "sentences.id is null" ]) do |t|
      logger.warn { "Token #{t.id} is orphaned" }
    end
  end

  # FIXME: should be superfluous by now. Keep for a little while, then
  # remove [May 09]
  def check_morphtag_validity(logger)
    Token.morphology_annotated.find_each(:include => :sentence) do |t|
      m = PROIEL::MorphTag.new(t.morphtag)
      logger.warn { "Token #{t.id} (#{t.form} in #{t.sentence.id}): Morphtag #{m} is invalid." } unless m.is_valid?(t.language.iso_code.to_sym)
    end
  end

  def check_lemmata(logger)
    orphans = Lemma.find(:all, :include => [ :tokens ], :conditions => [ "fixed = 0 AND lemmata.foreign_ids IS NULL and tokens.id IS NULL" ])
    orphans.each do |o| 
      logger.warn { "Lemma #{o.id} (#{o.export_form}) is orphaned. Destroying." }
      o.destroy
    end

    candidates = Lemma.find(:all, :conditions => [ "variant IS NOT NULL" ])
    candidates.each do |o|
      if c = o.language.lemmata.find(:first, :conditions => [ "lemma = ? and variant is null", o.lemma ])
        logger.warn { "Lemma base form #{o.lemma} occurs both with and without variant numbers" }
      end
    end

    Token.find_by_sql("select * from tokens left join lemmata on lemma_id = lemmata.id where substring(morphtag, 1, 2) != pos").each do |t|
      logger.warn { "#{t.sentence.id}: Token POS #{t.morph.pos_to_s} does not match lemma POS #{t.lemma.pos}" }
    end
  end

  def check_manual_morphology(logger)
    closed = "^(#{PROIEL::MorphTag::OPEN_MAJOR.map(&:to_s).join('|')})"
    Token.morphology_annotated.find_each(:conditions => [ "morphtag not rlike ?", closed ]) do |token|
      ml = token.morph_lemma_tag
      raise "Inconsistency! #{ml}" unless ml.morphtag.is_closed?

      next unless ml.morphtag.is_valid?(token.language.iso_code.to_sym)  # FIXME: at some point eliminate

      result, pick, *manual_tags = token.language.guess_morphology(token.form, nil, :force_method => :manual_rules)
      manual_tags = manual_tags ? manual_tags.map { |t| t[0] } : []

      case result
      when :failed
        log_token_error(logger, token, "Closed class morphological annotation #{ml.morphtag} but no rule entry")
      else
        unless manual_tags.any? { |m| token.morph_lemma_tag.morphtag.is_compatible?(m.morphtag) }
          log_token_error(logger, token, "Closed class morphological annotation #{token.morphtag} does not match expected #{manual_tags.collect { |m| m.morphtag.to_s }.join(', ')}")
        end
      end
    end
  end

  def log_token_error(logger, token, msg)
    logger.warn { "Token #{token.id} (sentence #{token.sentence.id}) '#{token.form}' (#{token.language.name}): #{msg}" }
  end
end
