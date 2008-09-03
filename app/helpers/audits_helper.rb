module AuditsHelper
  # Creates a summary view of a collection of audits.
  def audits_summary(audits)
    render(:partial => 'audits/legend') +
    content_tag(:ul, render(:partial => 'audits/summary', :collection => audits), :class => 'diff')
  end

  # Creates a table view of a collection of audits.
  def audit_table(audits)
    render_tabular audits, :partial => 'audits/audit', :pagination => true, :fields => [ 'User', 'Created at', 'Changed object', '&nbsp;' ]
  end

  # Creates a link to an audit.
  def link_to_audit(audit)
    link_to "Audit #{audit.id}", audit
  end

  # Creates a link to an audit user.
  def link_to_audit_user(user)
    if user
      link_to_user(user)
    else
      'System'
    end
  end

  # Creates a link to an auditable.
  def link_to_auditable(auditable)
    if auditable
      case auditable
      when Sentence
        link_to_sentence(auditable)
      when Token
        link_to_token(auditable)
      when Lemma
        link_to_lemma(auditable)
      else
        "#{auditable.class} #{auditable.id}"
      end
    else
      "(deleted)"
    end
  end

  DIFF_NIL_SYMBOL = ''

  def format_change(attribute, old_value, new_value)
    case attribute
    when 'sentence_id'
      old_value = old_value ? link_to(old_value, sentence_path(old_value)) : DIFF_NIL_SYMBOL
      new_value = new_value ? link_to(new_value, sentence_path(new_value)) : DIFF_NIL_SYMBOL
    when 'head_id'
      old_value = old_value ? link_to(old_value, token_path(old_value)) : DIFF_NIL_SYMBOL
      new_value = new_value ? link_to(new_value, token_path(new_value)) : DIFF_NIL_SYMBOL
    when 'lemma_id'
      old_value = old_value ? link_to(old_value, lemma_path(old_value)) : DIFF_NIL_SYMBOL
      new_value = new_value ? link_to(new_value, lemma_path(new_value)) : DIFF_NIL_SYMBOL
    end

    content_tag(:td, old_value || DIFF_NIL_SYMBOL, :class => "removed tag") +
    content_tag(:td, new_value || DIFF_NIL_SYMBOL, :class => "added tag")
  end
end
