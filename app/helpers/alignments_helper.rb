module AlignmentsHelper
  def unanchor_button(sentence)
    if sentence.sentence_alignment
      link_to_remote(image_tag("sweetie/16-security-lock-open.png", :alt => 'Remove anchor'),
        :url => { :controller => 'alignments', :action => 'set_unanchored', :id => sentence.id, })
    else
      ''
    end
  end

  def unalignable_button(sentence)
    if sentence.unalignable or sentence.sentence_alignment
      ''
    else
      link_to_remote(image_tag("sweetie/16-square-red-remove.png", :alt => 'Mark as unalignable'),
        :url => { :controller => 'alignments', :action => 'set_unalignable', :id => sentence.id, })
    end
  end

  def alignable_button(sentence)
    if sentence.unalignable
      link_to_remote(image_tag("sweetie/16-square-green-add.png", :alt => 'Mark as alignable'),
        :url => { :controller => 'alignments', :action => 'set_alignable', :id => sentence.id, })
    else
      ''
    end
  end
end
