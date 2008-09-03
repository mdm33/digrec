module ApplicationHelper
  # Inserts javascript files in the layout.
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  # Inserts stylesheets in the layout.
  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  # Returns an HTML block with formatted error messages.
  def error_messages(msg, *params)
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
    objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      header_message = "Error #{msg}:"
      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
      message(:error, "Error #{msg}:", content_tag(:ul, error_messages))  
    else
      ''
    end
  end

  def message(level, header, body = '')
    content_tag(:div, content_tag(:b, header) + body, :id => level)
  end

  # Generates a lemma and morphology description for a token.
  def readable_lemma_morphology(token, options = {})
    if token.lemma
      popup = []
      popup << "#{token.lemma.lemma}" if token.lemma
      popup << "(#{token.morph.descriptions([], false).join(', ')})" if token.morphtag
      popup.join(' ')
    else
      ''
    end
  end

  # Returns the contents of +value+ unless +value+ is +nil+, in which case it
  # returns the HTML entity for non-breakable space.
  def make_nonblank(value)
    value.nil? || value == '' ? '&nbsp;' : value
  end

  def _select_tag(name, value, option_tags, options = {}) #:nodoc:
    if options[:include_blank]
      options.delete(:include_blank)
      if value.nil? or value == ''
        select_tag name, "<option value='' selected='selected'></options>" + option_tags, options
      else
        select_tag name, "<option value=''></options>" + option_tags, options
      end
    else
      select_tag name, option_tags, options
    end
  end

  # Returns a select tag for languages.
  #
  # ==== Options
  # +:include_blank+:: If +true+, includes an empty value first.
  def language_select_tag(name, value = nil, options = {})
    value = value.to_sym unless value.nil? or value == '' 
    option_tags = PROIEL::LANGUAGES.collect do |code, values| 
      if code == value
        "<option value='#{code}' selected='selected'>#{values.summary}</option>"
      else
        "<option value='#{code}'>#{values.summary}</option>"
      end
    end.join

    _select_tag name, value, option_tags, options
  end

  # Returns a select tag for relations. 
  #
  # ==== Options
  # +:include_blank+:: If +true+, includes an empty value first.
  def relation_select_tag(name, value = nil, options = {})
    relations = PROIEL::RELATIONS.values.collect { |r| r.code.to_s }

    option_tags = relations.collect do |r| 
      if r == value
        "<option value='#{r}' selected='selected'>#{r.upcase}</option>"
      else
        "<option value='#{r}'>#{r.upcase}</option>"
      end
    end.join

    _select_tag name, value, option_tags, options
  end

  # Returns a select tag for completion rates. 
  #
  # ==== Options
  # +:include_blank+:: If +true+, includes an empty value first.
  def completion_select_tag(name, value = nil, options = {})
    value = value.to_sym unless value.nil? or value == ''
    vals = {
      :none => 'Not annotated', 
      :annotated => 'Annotated',
      :reviewed => 'Reviewed'
    }

    option_tags = vals.collect do |code, meaning| 
      if code == value
        "<option value='#{code}' selected='selected'>#{meaning}</option>"
      else
        "<option value='#{code}'>#{meaning}</option>"
      end
    end.join

    _select_tag name, value, option_tags, options
  end

  def _select_tag_db(name, model, value_field, value, options) #:nodoc:
    option_tags = options_from_collection_for_select(model.find(:all), :id, value_field, value.to_i)
    _select_tag name, value, option_tags, options
  end

  # Returns a select tag for sources.
  #
  # ==== Options
  # +:include_blank+:: If +true+, includes an empty value first.
  def source_select_tag(name, value, options = {})
    _select_tag_db(name, Source, :presentation_form, value, options)
  end

  # Returns a select tag for books.
  #
  # ==== Options
  # +:include_blank+:: If +true+, includes an empty value first.
  def book_select_tag(name, value, options = {})
    _select_tag_db(name, Book, :presentation_form, value, options)
  end

  # Returns a select tag for chapters. 
  #
  # ==== Options
  # +:include_blank+:: If +true+, includes an empty value first.
  def chapter_select_tag(name, value, options = {})
    option_tags = options_from_collection_for_select(Sentence.find(:all, :group => 'chapter'), :chapter, :chapter, value.to_i)
    _select_tag name, value, option_tags, options
  end

  # Enters Markaby "mode"; actually just a wrapper for the-semi ugly Markaby + helper hack.
  # Borrowed from http://railscasts.com/episodes/69.
  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end

  # Makes an information box intended for display of meta-data and navigational
  # aids.
  def make_information_box(entries)
    markaby do
      div.roundedbox do
        dl do
          entries.each do |title, data|
            dt "#{title}:"
            dd data
          end
        end
      end
    end
  end

  # Returns a radio button with a function as onclick handler.
  def radio_button_to_function(name, value, checked, *args, &block)
    html_options = args.extract_options!
    function = args[0] || ''

    html_options.symbolize_keys!
    function = update_page(&block) if block_given?
    tag(:input, html_options.merge({ 
        :type => "radio", :name => name, :value => value, :checked => checked,
        :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function};" 
    }))
  end

  # Generates a search form.
  def search_form_tag(submit_path, &block)
    html_options = html_options_for_form(submit_path, :method => 'get', :class => 'search')
    content = capture(&block)
    concat(form_tag_html(html_options), block.binding)
    concat(content, block.binding)
    concat(submit_tag('Search', :name => nil) + '</form>', block.binding)
  end

  # Generates a fancy tool-tip.
  def tool_tip(tool, tip)
    %Q{<span class="tool">#{tool}<span class="tip">#{tip}</span></span>}
  end

  # Generates a human readable representation of a token sort.
  def readable_token_sort(sort)
    sort.to_s.humanize
  end

  # Generates human readable POS information for a morphtag.
  def readable_pos(morphtag)
    make_nonblank(morphtag ? morphtag.descriptions([:major, :minor]).join(', ').capitalize : nil)
  end

  # Generates human readable morphology information for a morphtag. 
  def readable_morphology(morphtag)
    make_nonblank(morphtag ? morphtag.descriptions([:major, :minor], false).join(', ').capitalize : nil)
  end

  # Generates a human readable representation of a language code.
  #
  # ==== Example
  #  c = readable_language(:la)
  #  c # => "Latin"
  #
  def readable_language(code)
    make_nonblank(PROIEL::LANGUAGES[code].summary)
  end

  # Generates a human readable representation of a completion rate for a sentence.
  def readable_completion(sentence, options = {})
    if sentence.is_reviewed?
      s = "Reviewed"
    elsif sentence.is_annotated?
      s = "Annotated"
    else
      s = "Not annotated"
    end

    if options[:checkmark]
      if options[:checkmark] == :only
        c = '&nbsp;'
      else
        c = s
      end

      if sentence.is_reviewed?
        content_tag(:span, c, :class => 'reviewed')
      elsif sentence.is_annotated?
        content_tag(:span, c, :class => 'annotated')
      else
        content_tag(:span, c, :class => 'unannotated')
      end
    else
      s
    end
  end

  # Generates a human readble representation of a relation code.
  def readable_relation(code)
    return "<span class='relation bad'>#{code}</span>" unless code and PROIEL::RELATIONS.has_key?(code.to_sym)

    summary = PROIEL::RELATIONS[code].summary

    if summary
      "<span class='relation'><abbr title='#{summary.capitalize}'>#{code}</abbr></span>"
    else
      "<span class='relation'>#{code}</span>"
    end
  end

  # Generates a human readable representation of a dependency.
  def readable_dependency(relation, head)
    '(' + readable_relation(relation) + (head ? ", #{head}" : '') + ')'
  end

  # Generates a human readable location reference.
  def readable_reference(reference)
    "#{reference} (#{reference.classical_reference})"
  end

  # Generates a human readable 'yes'/'no' representation of a boolean value.
  def readable_boolean(x)
    x ? 'Yes' : 'No'
  end

  # Generates links to external Bible sites for a reference.
  def external_text_links(reference)
    [ link_to('Biblos', reference.external_url(:biblos), :class => 'external'),
      link_to('bibelen.no', reference.external_url(:bibelen_no), :class => 'external'), ].join('&nbsp;');
  end

  def wizard_options(ignore, options)
    s = ''
    if options
      c = controller.controller_name
      s << button_to('Edit', :controller => :wizard, :action => "modify_#{c}", :wizard => options, :annotation_id => params[:annotation_id]) if options[:edit] 
      s << button_to('Verify', :controller => :wizard, :action => "verify_#{c}", :wizard => options, :annotation_id => params[:annotation_id]) if options[:verify] 
      s << button_to('Skip', :controller => :wizard, :action => "skip_#{c}", :wizard => options, :annotation_id => params[:annotation_id]) if options[:skip] 
    elsif ignore
      s << button_to('Edit', { :action => 'edit', :method => 'get' }, :method => 'get' )
    end
    s
  end

  # Generates a rounded box with a description list inside.
  def roundedbox(&block)
    content = capture(&block)
    concat("<div class='roundedbox'><dl>", block.binding)
    concat(content, block.binding)
    concat("</dl></div>", block.binding)
  end

  # Generates a title header and a set of associated links directly
  # next to the header.
  def layer(id, options = {}, &block)
    title = options[:title]
    title ||= id.humanize
    actions = options[:actions]
    actions = "(#{actions.join(' | ')})" if actions

    content = capture(&block)
    concat("<div id='#{id}' class='layer'><h1 class='layer-title'>#{title}</h1> <span class='layer-actions'>#{actions}</span><div class='layer-content'>", block.binding)
    concat(content, block.binding)
    concat("</div></div>", block.binding)
  end

  # Generates a title header and a set of associated links directly
  # next to the header if the condition +condition+ is +true+. Otherwise
  # takes no action. The remainin arguments are the same as for
  # +layer+.
  def layer_if(condition, *args, &block)
    condition ? layer(*args, &block) : ''
  end

  # Generates a title header and a set of associated links directly
  # next to the header unless the condition +condition+ is +true+. Otherwise
  # takes no action. The remainin arguments are the same as for
  # +layer+.
  def layer_unless(condition, *args, &block)
    layer_if(!condition, *args, &block)
  end

  def format_ratio(part, total)
    number_with_precision(part.to_i * 100 / total.to_f, 1) + '%'
  end

  # Creates hidden 'Previous' and 'Next' links for per-sentence annotation displays
  # with standard access keys P and N.
  def annotation_navigation_links(sentence, url_function)
    link_to_if(sentence.has_previous_sentence?, 'Previous', self.send(url_function, sentence.previous_sentence),
               :accesskey => 'p') + '&nbsp;' +
    link_to_if(sentence.has_next_sentence?, 'Next', self.send(url_function, sentence.next_sentence),
               :accesskey => 'n')
  end

  # Generates a link if the condition +condition+ is +true+, otherwise
  # takes no action. The remaining arguments are the same as those 
  # for +link_to+.
  def show_link_to_if(condition, *args)
    condition ? link_to(*args) : ''
  end

  # Generates a link if the current user has the role +role+, otherwise
  # takes no action. The remaining arguments are the same as those for 
  # +link_to+.
  def show_link_to_for_role(role, *args)
    show_link_to_if(current_user.has_role?(role), *args)
  end

  # Outputs an error messages block.
  #
  # ==== Options
  # * :on => :products   Also includes AR validation errors for @products
  # * :clear => true     Clears messages after displaying
  # * :keep => true      Keeps around messages for next response cycle
  #
  def message_block(options = {})
    options.reverse_merge! :keep => false, :clear => true
    out = ""

    [:error, :notice].each do |type|
      next if flash[type].nil? or flash[type].empty?
      flash[type] = [flash[type]] unless flash[type].is_a?(Array)

      out << "<div class=\"message-block #{type}\"><ul>\n"
      flash[type].each {|msg| out << "<li>#{h(msg.to_s)}</li>\n"}
      out << "</ul></div>\n"

      flash[type] = nil if options[:clear]
      flash.keep[type] if options[:keep]
    end

    if options[:on]
      options[:on] = [options[:on]] unless options[:on].kind_of?(Array)
      models = options[:on].map { |m| instance_variable_get("@" + m.to_s) }.select { |m| !m.nil? }
      errors = models.inject([]) { |b, m| b += m.errors.full_messages }  

      if errors.size > 0
        out << "<div class=\"message-block error\"><ul>\n"
        errors.each {|msg| out << "<li>#{h(msg.to_s)}</li>\n"}
        out << "</ul></div>\n"
      end
    end
    content_tag(:div, out, :class => 'flash')
  end

  # Formats a token form with HTML language attributes.
  def format_token_form(token)
    LangString.new(token.form, token.language).to_h
  end

  # Formats a token presentation form with HTML language attributes.
  def format_token_presentation_form(token)
    LangString.new(token.presentation_form, token.language).to_h
  end

  # Formats a lemma form with HTML language attributes.
  def format_lemma_form(lemma)
    LangString.new(lemma.lemma, lemma.language).to_h
  end

  # Formats a language-dependent string with HTML language attributes.
  def format_language_string(s, language)
    LangString.new(s, language).to_h
  end

  # Creates resource links for an object.
  def link_to_resources(object, *actions)
    actions.map do |action|
      case action
      when :index
        link_to_index(object)
      when :edit
        link_to_edit(object)
      when :delete
        link_to_delete(object)
      end
    end.join(' ')
  end

  # Creates a resource index link for an object.
  def link_to_index(object)
    link_to('Index', send("#{object.class.to_s.underscore.pluralize}_url"), :class => :index)
  end

  # Creates a resource edit link for an object.
  def link_to_edit(object)
    link_to('Edit', send("edit_#{object.class.to_s.underscore}_url"), :class => :edit)
  end

  # Creates a resource delete link for an object.
  def link_to_delete(object)
    link_to('Delete', object, :method => :delete, :confirm => 'Are you sure?', :class => :delete)
  end
end
