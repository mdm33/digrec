# encoding: UTF-8
#--
#
# Copyright 2009, 2010, 2011, 2012, 2013 University of Oslo
# Copyright 2009, 2010, 2011, 2012, 2013 Marius L. Jøhndal
# New material copyright 2019, 2020 by Morgan Macleod
#
# This file is part of the PROIEL web application.
#
# The PROIEL web application is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# The PROIEL web application is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the PROIEL web application.  If not, see
# <http://www.gnu.org/licenses/>.
#
#++

class TokensController < ApplicationController
  respond_to :html
  before_filter :is_administrator?, :only => [:edit, :update]

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def show
    @token = Token.includes(:sentence => [:source_division => [:source]]).find(params[:id])

    if @token.nil?
      raise ActiveRecord::RecordNotFound
    else
      @sentence = @token.sentence
      @source_division = @sentence.source_division
      @source = @source_division.source

      @semantic_tags = @token.semantic_tags
      # Add semantic tags from lemma not present in the token's semantic tags.
      @semantic_tags += @token.lemma.semantic_tags.reject { |tag| @semantic_tags.map(&:semantic_attribute).include?(tag.semantic_attribute) } if @token.lemma

      @outgoing_semantic_relations = @token.outgoing_semantic_relations
      @incoming_semantic_relations = @token.incoming_semantic_relations

      @notes = @token.notes
      @audits = @token.audits

      respond_with @token
    end
  end

  def edit
    @token = Token.includes(:sentence => [:source_division => [:source]]).find(params[:id])

    if @token.nil?
      raise ActiveRecord::RecordNotFound
    else
      @sentence = @token.sentence
      @source_division = @sentence.source_division
      @source = @source_division.source

      respond_with @token
    end
  end

  def update
    normalize_unicode_params! params[:token], :presentation_before, :presentation_after, :form

    @token = Token.find(params[:id])
    @token.update_attributes(params[:token])
    if params[:animacy] == "a"
      semtag = 1
    elsif params[:animacy] == "i"
      semtag = 2
    elsif params[:animacy] == "p"
      semtag = 3
    else
      semtag = 0
    end
    q = @token.sem_tags_to_hash
    if q.has_key?("animacy")
      tag = SemanticTag.where("taggable_id = ? AND taggable_type = 'Token'", @token.id).first
      if semtag == 0
        tag.destroy
      else
        tag.semantic_attribute_value_id = semtag
        tag.save
      end
    elsif semtag > 0
      attribute = SemanticAttribute.find_by_tag("animacy")
      value = attribute.semantic_attribute_values.find(semtag)
      @token.semantic_tags.create(:semantic_attribute_value => value)
    end

    respond_with @token
  end

  def dependency_alignment_group
    @token = Token.find(params[:id])
    alignment_set, edge_count = @token.dependency_alignment_set

    render :json => { :alignment_set => alignment_set.map(&:id), :edge_count => edge_count }
  end

  def index
    if params[:q]
      if params[:q][:form_wildcard_matches]
        params[:q][:form_wildcard_matches] = TokensController.beta_decode(params[:q][:form_wildcard_matches])
      end
      if params[:q][:lemma_lemma_wildcard_matches]
        params[:q][:lemma_lemma_wildcard_matches] = TokensController.beta_decode(params[:q][:lemma_lemma_wildcard_matches])
      end
    end
    @search = Token.search(params[:q])
    # Location sorts are actually multi-sorts. Inspecting @search.sorts may
    # seem like the sensible solution to this, but this is actually an array of
    # non-inspectable objects. We'll instead peek at params[:q][:s] and
    # instruct ransack what to do based on its value.
    sort_order = params[:q] ? params[:q][:s] : nil

    case sort_order
    when NilClass, '', 'location asc' # default
      @search.sorts = ['sentence_source_division_source_id asc',
                       'sentence_source_division_position asc',
                       'sentence_sentence_number asc',
                       'token_number asc']
    when 'location desc'
      @search.sorts = ['sentence_source_division_source_id desc',
                       'sentence_source_division_position desc',
                       'sentence_sentence_number desc',
                       'token_number desc']
    else
      # Do nothing; ransack has already taken care of it.
    end

    respond_to do |format|
      if params[:animacy] == "a"
        semtag = 1
      elsif params[:animacy] == "i"
        semtag = 2
      elsif params[:animacy] == "p"
        semtag = 3
      else
        semtag = 0
      end
      if semtag > 0
        @x = @search.result.joins("LEFT OUTER JOIN semantic_tags ON semantic_tags.taggable_id = tokens.id").where("semantic_tags.taggable_type='Token' AND semantic_attribute_value_id = ?", semtag)
      else
        @x = @search.result
      end
      format.html do
        @tokens = @x.page(current_page)
      end
      format.csv do
        if @x.count > 5000
          head :no_content
        end
      end
      format.txt do
        if @x.count > 5000
          head :no_content
        end
      end
    end
  end

  def quick_search
    q = params[:q].strip
    q = TokensController.beta_decode(q)

    case q
    when '' # reload the same page
      redirect_to :back
    when /^\d+$/ # look up a sentence ID
      redirect_to sentence_url(q.to_i)
    else # match against token forms
      redirect_to tokens_url(:q => { :form_wildcard_matches => "#{q}*" })
    end
  end

  def opensearch
    response.headers['Content-Type'] = 'application/opensearchdescription+xml; charset=utf-8'
  end
  
  def TokensController.beta_decode(txtin)
    if txtin.ascii_only?
      k = 0
      txtout = ""
      chars = [""]
      txtin.downcase.each_char do |x|
        val = x.codepoints[0]
        if chars[k].length > 0 && (chars[k][0] != "*" || txtout.codepoints[0] >= 0x61) && ((val >= 0x61 && val <= 0x7A) || x == "?")
          k = k + 1
          chars.push(x)
		else
          chars[k] = chars[k] + x
        end
        txtout = x
      end
      txtout = ""
      chars.each do |x|
        case x
          when "*a/", "*/a"
            txtout = txtout + "\u0386"
          when "*e/", "*/e"
            txtout = txtout + "\u0388"
          when "*h/", "*/h"
            txtout = txtout + "\u0389"
          when "*i/", "*/i"
            txtout = txtout + "\u038A"
          when "*o/", "*/o"
            txtout = txtout + "\u038C"
          when "*u/", "*/u"
            txtout = txtout + "\u038E"
          when "*w/", "*/w"
            txtout = txtout + "\u038F"
          when "i+/"
            txtout = txtout + "\u0390"
          when "*a"
            txtout = txtout + "\u0391"
          when "*b"
            txtout = txtout + "\u0392"
          when "*g"
            txtout = txtout + "\u0393"
          when "*d"
            txtout = txtout + "\u0394"
          when "*e"
            txtout = txtout + "\u0395"
          when "*z"
            txtout = txtout + "\u0396"
          when "*h"
            txtout = txtout + "\u0397"
          when "*q"
            txtout = txtout + "\u0398"
          when "*i"
            txtout = txtout + "\u0399"
          when "*k"
            txtout = txtout + "\u039A"
          when "*l"
            txtout = txtout + "\u039B"
          when "*m"
            txtout = txtout + "\u039C"
          when "*n"
            txtout = txtout + "\u039D"
          when "*c"
            txtout = txtout + "\u039E"
          when "*o"
            txtout = txtout + "\u039F"
          when "*p"
            txtout = txtout + "\u03A0"
          when "*r"
            txtout = txtout + "\u03A1"
          when "*s"
            txtout = txtout + "\u03A3"
          when "*t"
            txtout = txtout + "\u03A4"
          when "*u"
            txtout = txtout + "\u03A5"
          when "*f"
            txtout = txtout + "\u03A6"
          when "*x"
            txtout = txtout + "\u03A7"
          when "*y"
            txtout = txtout + "\u03A8"
          when "*w"
            txtout = txtout + "\u03A9"
          when "*i+"
            txtout = txtout + "\u03AA"
          when "*u+"
            txtout = txtout + "\u03AB"
          when "a/"
            txtout = txtout + "\u03AC"
          when "e/"
            txtout = txtout + "\u03AD"
          when "h/"
            txtout = txtout + "\u03AE"
          when "i/"
            txtout = txtout + "\u03AF"
          when "u+/"
            txtout = txtout + "\u03B0"
          when "a"
            txtout = txtout + "\u03B1"
          when "b"
            txtout = txtout + "\u03B2"
          when "g"
            txtout = txtout + "\u03B3"
          when "d"
            txtout = txtout + "\u03B4"
          when "e"
            txtout = txtout + "\u03B5"
          when "z"
            txtout = txtout + "\u03B6"
          when "h"
            txtout = txtout + "\u03B7"
          when "q"
            txtout = txtout + "\u03B8"
          when "i"
            txtout = txtout + "\u03B9"
          when "k"
            txtout = txtout + "\u03BA"
          when "l"
            txtout = txtout + "\u03BB"
          when "m"
            txtout = txtout + "\u03BC"
          when "n"
            txtout = txtout + "\u03BD"
          when "c"
            txtout = txtout + "\u03BE"
          when "o"
            txtout = txtout + "\u03BF"
          when "p"
            txtout = txtout + "\u03C0"
          when "r"
            txtout = txtout + "\u03C1"
          when "s"
            txtout = txtout + "\u03C3"
          when "t"
            txtout = txtout + "\u03C4"
          when "u"
            txtout = txtout + "\u03C5"
          when "f"
            txtout = txtout + "\u03C6"
          when "x"
            txtout = txtout + "\u03C7"
          when "y"
            txtout = txtout + "\u03C8"
          when "w"
            txtout = txtout + "\u03C9"
          when "i+"
            txtout = txtout + "\u03CA"
          when "u+"
            txtout = txtout + "\u03CB"
          when "o/"
            txtout = txtout + "\u03CC"
          when "u/"
            txtout = txtout + "\u03CD"
          when "w/"
            txtout = txtout + "\u03CE"
          when "*v"
            txtout = txtout + "\u03DC"
          when "v"
            txtout = txtout + "\u03DD"
          when "a)"
            txtout = txtout + "\u1F00"
          when "a("
            txtout = txtout + "\u1F01"
          when "a)\\"
            txtout = txtout + "\u1F02"
          when "a(\\"
            txtout = txtout + "\u1F03"
          when "a)/"
            txtout = txtout + "\u1F04"
          when "a(/"
            txtout = txtout + "\u1F05"
          when "a)="
            txtout = txtout + "\u1F06"
          when "a(="
            txtout = txtout + "\u1F07"
          when "*a)", "*)a"
            txtout = txtout + "\u1F08"
          when "*a(", "*(a"
            txtout = txtout + "\u1F09"
          when "*a)\\", "*)\\a"
            txtout = txtout + "\u1F0A"
          when "*a(\\", "*(\\a"
            txtout = txtout + "\u1F0B"
          when "*a)/", "*)/a"
            txtout = txtout + "\u1F0C"
          when "*a(/", "*(/a"
            txtout = txtout + "\u1F0D"
          when "*a)=", "*)=a"
            txtout = txtout + "\u1F0E"
          when "*a(=", "*(=a"
            txtout = txtout + "\u1F0F"
          when "e)"
            txtout = txtout + "\u1F10"
          when "e("
            txtout = txtout + "\u1F11"
          when "e)\\"
            txtout = txtout + "\u1F12"
          when "e(\\"
            txtout = txtout + "\u1F13"
          when "e)/"
            txtout = txtout + "\u1F14"
          when "e(/"
            txtout = txtout + "\u1F15"
          when "*e)", "*)e"
            txtout = txtout + "\u1F18"
          when "*e(", "*(e"
            txtout = txtout + "\u1F19"
          when "*e)\\", "*)\\e"
            txtout = txtout + "\u1F1A"
          when "*e(\\", "*(\\e"
            txtout = txtout + "\u1F1B"
          when "*e)/", "*)/e"
            txtout = txtout + "\u1F1C"
          when "*e(/", "*(/e"
            txtout = txtout + "\u1F1D"
          when "h)"
            txtout = txtout + "\u1F20"
          when "h("
            txtout = txtout + "\u1F21"
          when "h)\\"
            txtout = txtout + "\u1F22"
          when "h(\\"
            txtout = txtout + "\u1F23"
          when "h)/"
            txtout = txtout + "\u1F24"
          when "h(/"
            txtout = txtout + "\u1F25"
          when "h)="
            txtout = txtout + "\u1F26"
          when "h(="
            txtout = txtout + "\u1F27"
          when "*h)", "*)h"
            txtout = txtout + "\u1F28"
          when "*h(", "*(h"
            txtout = txtout + "\u1F29"
          when "*h)\\", "*)\\h"
            txtout = txtout + "\u1F2A"
          when "*h(\\", "*(\\h"
            txtout = txtout + "\u1F2B"
          when "*h)/", "*)/h"
            txtout = txtout + "\u1F2C"
          when "*h(/", "*(/h"
            txtout = txtout + "\u1F2D"
          when "*h)=", "*)=h"
            txtout = txtout + "\u1F2E"
          when "*h(=", "*(=h"
            txtout = txtout + "\u1F2F"
          when "i)"
            txtout = txtout + "\u1F30"
          when "i("
            txtout = txtout + "\u1F31"
          when "i)\\"
            txtout = txtout + "\u1F32"
          when "i(\\"
            txtout = txtout + "\u1F33"
          when "i)/"
            txtout = txtout + "\u1F34"
          when "i(/"
            txtout = txtout + "\u1F35"
          when "i)="
            txtout = txtout + "\u1F36"
          when "i(="
            txtout = txtout + "\u1F37"
          when "*i)", "*)i"
            txtout = txtout + "\u1F38"
          when "*i(", "*(i"
            txtout = txtout + "\u1F39"
          when "*i)\\", "*)\\i"
            txtout = txtout + "\u1F3A"
          when "*i(\\", "*(\\i"
            txtout = txtout + "\u1F3B"
          when "*i)/", "*)/i"
            txtout = txtout + "\u1F3C"
          when "*i(/", "*(/i"
            txtout = txtout + "\u1F3D"
          when "*i)=", "*)=i"
            txtout = txtout + "\u1F3E"
          when "*i(=", "*(=i"
            txtout = txtout + "\u1F3F"
          when "o)"
            txtout = txtout + "\u1F40"
          when "o("
            txtout = txtout + "\u1F41"
          when "o)\\"
            txtout = txtout + "\u1F42"
          when "o(\\"
            txtout = txtout + "\u1F43"
          when "o)/"
            txtout = txtout + "\u1F44"
          when "o(/"
            txtout = txtout + "\u1F45"
          when "*o)", "*)o"
            txtout = txtout + "\u1F48"
          when "*o(", "*(o"
            txtout = txtout + "\u1F49"
          when "*o)\\", "*)\\o"
            txtout = txtout + "\u1F4A"
          when "*o(\\", "*(\\o"
            txtout = txtout + "\u1F4B"
          when "*o)/", "*)/o"
            txtout = txtout + "\u1F4C"
          when "*o(/", "*(/o"
            txtout = txtout + "\u1F4D"
          when "u)"
            txtout = txtout + "\u1F50"
          when "u("
            txtout = txtout + "\u1F51"
          when "u)\\"
            txtout = txtout + "\u1F52"
          when "u(\\"
            txtout = txtout + "\u1F53"
          when "u)/"
            txtout = txtout + "\u1F54"
          when "u(/"
            txtout = txtout + "\u1F55"
          when "u)="
            txtout = txtout + "\u1F56"
          when "u(="
            txtout = txtout + "\u1F57"
          when "*u(", "*(u"
            txtout = txtout + "\u1F59"
          when "*u(\\", "*(\\u"
            txtout = txtout + "\u1F5B"
          when "*u(/", "*(/u"
            txtout = txtout + "\u1F5D"
          when "*u(=", "*(=u"
            txtout = txtout + "\u1F5F"
          when "w)"
            txtout = txtout + "\u1F60"
          when "w("
            txtout = txtout + "\u1F61"
          when "w)\\"
            txtout = txtout + "\u1F62"
          when "w(\\"
            txtout = txtout + "\u1F63"
          when "w)/"
            txtout = txtout + "\u1F64"
          when "w(/"
            txtout = txtout + "\u1F65"
          when "w)="
            txtout = txtout + "\u1F66"
          when "w(="
            txtout = txtout + "\u1F67"
          when "*w)", "*)w"
            txtout = txtout + "\u1F68"
          when "*w(", "*(w"
            txtout = txtout + "\u1F69"
          when "*w)\\", "*)\\w"
            txtout = txtout + "\u1F6A"
          when "*w(\\", "*(\\w"
            txtout = txtout + "\u1F6B"
          when "*w)/", "*)/w"
            txtout = txtout + "\u1F6C"
          when "*w(/", "*(/w"
            txtout = txtout + "\u1F6D"
          when "*w)=", "*)=w"
            txtout = txtout + "\u1F6E"
          when "*w(=", "*(=w"
            txtout = txtout + "\u1F6F"
          when "a\\"
            txtout = txtout + "\u1F70"
          when "e\\"
            txtout = txtout + "\u1F72"
          when "h\\"
            txtout = txtout + "\u1F74"
          when "i\\"
            txtout = txtout + "\u1F76"
          when "o\\"
            txtout = txtout + "\u1F78"
          when "u\\"
            txtout = txtout + "\u1F7A"
          when "w\\"
            txtout = txtout + "\u1F7C"
          when "a)|"
            txtout = txtout + "\u1F80"
          when "a(|"
            txtout = txtout + "\u1F81"
          when "a)\\|"
            txtout = txtout + "\u1F82"
          when "a(\\|"
            txtout = txtout + "\u1F83"
          when "a)/|"
            txtout = txtout + "\u1F84"
          when "a(/|"
            txtout = txtout + "\u1F85"
          when "a)=|"
            txtout = txtout + "\u1F86"
          when "a(=|"
            txtout = txtout + "\u1F87"
          when "*a)|", "*)a|"
            txtout = txtout + "\u1F88"
          when "*a(|", "*(a|"
            txtout = txtout + "\u1F89"
          when "*a)\\|", "*)\\a|"
            txtout = txtout + "\u1F8A"
          when "*a(\\|", "*(\\a|"
            txtout = txtout + "\u1F8B"
          when "*a)/|", "*)/a|"
            txtout = txtout + "\u1F8C"
          when "*a(/|", "*(/a|"
            txtout = txtout + "\u1F8D"
          when "*a)=|", "*)=a|"
            txtout = txtout + "\u1F8E"
          when "*a(=|", "*(=a|"
            txtout = txtout + "\u1F8F"
          when "h)|"
            txtout = txtout + "\u1F90"
          when "h(|"
            txtout = txtout + "\u1F91"
          when "h)\\|"
            txtout = txtout + "\u1F92"
          when "h(\\|"
            txtout = txtout + "\u1F93"
          when "h)/|"
            txtout = txtout + "\u1F94"
          when "h(/|"
            txtout = txtout + "\u1F95"
          when "h)=|"
            txtout = txtout + "\u1F96"
          when "h(=|"
            txtout = txtout + "\u1F97"
          when "*h)|", "*)h|"
            txtout = txtout + "\u1F98"
          when "*h(|", "*(h|"
            txtout = txtout + "\u1F99"
          when "*h)\\|", "*)\\h|"
            txtout = txtout + "\u1F9A"
          when "*h(\\|", "*(\\h|"
            txtout = txtout + "\u1F9B"
          when "*h)/|", "*)/h|"
            txtout = txtout + "\u1F9C"
          when "*h(/|", "*(/h|"
            txtout = txtout + "\u1F9D"
          when "*h)=|", "*)=h|"
            txtout = txtout + "\u1F9E"
          when "*h(=|", "*(=h|"
            txtout = txtout + "\u1F9F"
          when "w)|"
            txtout = txtout + "\u1FA0"
          when "w(|"
            txtout = txtout + "\u1FA1"
          when "w)\\|"
            txtout = txtout + "\u1FA2"
          when "w(\\|"
            txtout = txtout + "\u1FA3"
          when "w)/|"
            txtout = txtout + "\u1FA4"
          when "w(/|"
            txtout = txtout + "\u1FA5"
          when "w)=|"
            txtout = txtout + "\u1FA6"
          when "w(=|"
            txtout = txtout + "\u1FA7"
          when "*w)|", "*)w|"
            txtout = txtout + "\u1FA8"
          when "*w(|", "*(w|"
            txtout = txtout + "\u1FA9"
          when "*w)\\|", "*)\\w|"
            txtout = txtout + "\u1FAA"
          when "*w(\\|", "*(\\w|"
            txtout = txtout + "\u1FAB"
          when "*w)/|", "*)/w|"
            txtout = txtout + "\u1FAC"
          when "*w(/|", "*(/w|"
            txtout = txtout + "\u1FAD"
          when "*w)=|", "*)=w|"
            txtout = txtout + "\u1FAE"
          when "*w(=|", "*(=w|"
            txtout = txtout + "\u1FAF"
          when "a\\|"
            txtout = txtout + "\u1FB2"
          when "a|"
            txtout = txtout + "\u1FB3"
          when "a/|"
            txtout = txtout + "\u1FB4"
          when "a="
            txtout = txtout + "\u1FB6"
          when "a=|"
            txtout = txtout + "\u1FB7"
          when "*a\\", "*\\a"
            txtout = txtout + "\u1FBA"
          when "*a/", "*/a"
            txtout = txtout + "\u1FBB"
          when "*a|"
            txtout = txtout + "\u1FBC"
          when "h\\|"
            txtout = txtout + "\u1FC2"
          when "h|"
            txtout = txtout + "\u1FC3"
          when "h/|"
            txtout = txtout + "\u1FC4"
          when "h="
            txtout = txtout + "\u1FC6"
          when "h=|"
            txtout = txtout + "\u1FC7"
          when "*e\\", "*\\e"
            txtout = txtout + "\u1FC8"
          when "*e/", "*/e"
            txtout = txtout + "\u1FC9"
          when "*h\\", "*\\h"
            txtout = txtout + "\u1FCA"
          when "*h/", "*/h"
            txtout = txtout + "\u1FCB"
          when "*h|"
            txtout = txtout + "\u1FCC"
          when "i+\\"
            txtout = txtout + "\u1FD2"
          when "i="
            txtout = txtout + "\u1FD6"
          when "i+="
            txtout = txtout + "\u1FD7"
          when "*i\\", "*\\i"
            txtout = txtout + "\u1FDA"
          when "*i/", "*/i"
            txtout = txtout + "\u1FDB"
          when "u+\\"
            txtout = txtout + "\u1FE2"
          when "r)"
            txtout = txtout + "\u1FE4"
          when "r("
            txtout = txtout + "\u1FE5"
          when "u="
            txtout = txtout + "\u1FE6"
          when "u+="
            txtout = txtout + "\u1FE7"
          when "*u\\", "*\\u"
            txtout = txtout + "\u1FEA"
          when "*u/", "*/u"
            txtout = txtout + "\u1FEB"
          when "*r(", "*(r"
            txtout = txtout + "\u1FEC"
          when "w\\|"
            txtout = txtout + "\u1FF2"
          when "w|"
            txtout = txtout + "\u1FF3"
          when "w/|"
            txtout = txtout + "\u1FF4"
          when "w="
            txtout = txtout + "\u1FF6"
          when "w=|"
            txtout = txtout + "\u1FF7"
          when "*o\\", "*\\o"
            txtout = txtout + "\u1FF8"
          when "*o/", "*/o"
            txtout = txtout + "\u1FF9"
          when "*w\\", "*\\w"
            txtout = txtout + "\u1FFA"
          when "*w/", "*/w"
            txtout = txtout + "\u1FFB"
          when "*w|"
            txtout = txtout + "\u1FFC"
          else
            txtout = txtout + x
        end
      end
      if txtout[txtout.length - 1] == "\u03C3"
        txtout = txtout[0, txtout.length - 1] + "\u03C2"
      end
      txtout
    else
      txtin
    end
  end
end
