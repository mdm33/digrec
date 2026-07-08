#--
#
# Copyright 2009, 2010, 2011, 2012, 2015 University of Oslo
# Copyright 2009, 2010, 2011, 2012, 2015 Marius L. Jøhndal
# New material copyright 2023, 2026 by Morgan Macleod
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

class SentencesController < ApplicationController
  respond_to :html
  before_action :is_reviewer?, :only => [:edit, :update, :flag_as_reviewed, :flag_as_not_reviewed]

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def show
    @sentence = Sentence.includes(:source_division => [:source],
                                  :tokens => [:lemma, :notes],
                                  :notes => []).find(params[:id])
    @source_division = @sentence.source_division
    @source = @source_division.try(:source)

    @sentence_window = @sentence.sentence_window.includes(:tokens)
    @semantic_tags = @sentence.semantic_tags

    @notes = @sentence.notes
    #@audits = @sentence.audits

    respond_with @sentence
  end
  
  def new
	@sentence = Sentence.new
	@sentence.source_division = SourceDivision.find(params[:source_division])
	
	respond_with @sentence
  end

  def edit
    @sentence = Sentence.includes(:source_division => [:source]).find(params[:id])
    @source_division = @sentence.try(:source_division)
    @source = @source_division.try(:source)

    respond_with @sentence
  end
  
  def create
    @source = SourceDivision.find(params[:sentence][:source_division])
	idnum = @source.id - @source.id
	cit = ""
	guess = false
	
    if params[:sentence][:assigned_to].nil?
	  flash[:error] = "No sentence content"
	  redirect_to @source
	  return
	end
	if params[:sentence][:assigned_to] == ""
	  flash[:error] = "No sentence content"
	  redirect_to @source
	  return
	end
	unless params[:sentence][:unalignable].nil?
	  guess = (params[:sentence][:unalignable] == "1")
	end
	
	unless params[:sentence][:id].nil?
	  unless params[:sentence][:id] == ""
	    idnum = params[:sentence][:id].to_i
	  end
	end
	
	if idnum > 0
	  idnum = Sentence.find(idnum).sentence_number
	else
	  s = Sentence.where("source_division_id = ?",@source.id).order(:sentence_number).last
	  if s.nil?
	    idnum = 0
	  else
	    idnum = s.sentence_number + 1
	  end
	end
	
    normalize_unicode_params! params[:sentence], :presentation_before, :presentation_after, :annotated_by, :assigned_to
	
	ActiveRecord::Base.connection.execute "UPDATE sentences SET sentence_number = sentence_number+1 WHERE sentence_number >= #{idnum} AND source_division_id = #{@source.id};"
	@sentence = Sentence.new
	@sentence.source_division = @source
	@sentence.sentence_number = idnum	
	@sentence.status_tag = "unannotated"	
	
	unless params[:sentence][:presentation_before].nil?
	  unless params[:sentence][:presentation_before] == ""
	    @sentence.presentation_before = params[:sentence][:presentation_before]
	  end
	end
	unless params[:sentence][:presentation_after].nil?
	  unless params[:sentence][:presentation_after] == ""
	    @sentence.presentation_after = params[:sentence][:presentation_after]
	  end
	end
	unless params[:sentence][:annotated_by].nil?
	  unless params[:sentence][:annotated_by] == ""
	    cit = params[:sentence][:annotated_by]
	  end
	end
	
	@sentence.save
	@sentence.populate(params[:sentence][:assigned_to], cit, guess)
	respond_with @sentence
  end

  def update
    normalize_unicode_params! params[:sentence], :presentation_before, :presentation_after

    @sentence = Sentence.find(params[:id])
    @sentence.update_attributes(params[:sentence])

    flash[:notice] = 'Sentence was successfully updated.'

    respond_with @sentence
  end

  def flag_as_reviewed
    @sentence = Sentence.find(params[:id])

    @sentence.set_reviewed!(current_user)
    flash[:notice] = 'Sentence was successfully updated.'
    redirect_to @sentence
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = invalid.record.errors.full_messages.map { |m| "#{invalid.record.class} #{invalid.record.id}: #{m}" }.join('<br>')
    redirect_to @sentence
  end

  def flag_as_not_reviewed
    @sentence = Sentence.find(params[:id])

    @sentence.unset_reviewed!(current_user)
    flash[:notice] = 'Sentence was successfully updated.'
    redirect_to @sentence
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = invalid.record.errors.full_messages.join('<br>')
    redirect_to @sentence
  end

  def export
    @sentence = Sentence.find(params[:id])

    result = LatexGlossingExporter.instance.generate(@sentence)

    respond_to do |format|
      format.html { send_data result, disposition: 'inline', type: :html }
    end
  end
end
