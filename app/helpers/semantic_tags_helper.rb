module SemanticTagsHelper
  # Creates a summary view of a collection of semantic tags.
  def semantic_tags_summary(semantic_tags)
    content_tag(:ul, render(:partial => 'semantic_tags/summary', :collection => semantic_tags))
  end

  # Creates a table view of a collection of semantic attribute values.
  def semantic_tags_table(semantic_tags)
    render_tabular semantic_tags, :pagination => true, :fields => [ 'Reference', 'Tag', '&nbsp;' ]
  end

  # Creates a readable semantic attribute + attribute-value pair.
  def readable_semantic_attribute_value(semantic_attribute, semantic_attribute_value, hlight = nil)
    content_tag(:span, [highlight(semantic_attribute.tag, hlight), highlight(semantic_attribute_value.tag, hlight)].join(' = '), :class => 'tag')
  end

  # Creates a link to a semantic tag taggable.
  def link_to_semantic_tag_taggable(taggable)
    case taggable
    when Token
      link_to_token(taggable)
    when Lemma
      link_to_lemma(taggable)
    else
      raise ArgumentError, "invalid taggable"
    end
  end
end
