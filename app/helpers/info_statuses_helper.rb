module InfoStatusesHelper
  def format_sentences_for_info_status(sentences)
    format_sentence(sentences, :information_status => true, :citations => true,
                    :highlight => @sentence) do |token|
      css = []
      css << "con-#{token.contrast_group}" if token.contrast_group

      if token.sentence == @sentence
        if token.information_status_tag and token.information_status_tag != 'info_unannotatable'
          css << 'info-annotatable'
          css << token.information_status_tag.dasherize
        elsif token.is_annotatable?
          css << 'info-annotatable'
          css << 'no-info-status'
        else
          css << 'info-unannotatable'
        end
        css << "ant-#{token.antecedent.id}" if token.antecedent
        css << 'verb' if token.verb?
      end

      { :class => css * ' ', :id => "token-#{token.id}" }
    end
  end
end
