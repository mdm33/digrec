#--
#
# Copyright 2007, 2008, 2009, 2010, 2011, 2012 University of Oslo
# Copyright 2007, 2008, 2009, 2010, 2011, 2012 Marius L. Jøhndal
# New material copyright 2023 by Morgan Macleod
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

class SourceDivisionsController < ApplicationController
  respond_to :html, :xml
  before_filter :is_administrator?, :only => [:edit, :update]

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def show
    @source_division = SourceDivision.includes(:source).find(params[:id])
    @source = @source_division.source
    @sentences = @source_division.sentences.order(:sentence_number).page(current_page).per(90)

    respond_with @source_division
  end
  
  def new
	@source_division = SourceDivision.new
	@source_division.source = Source.find(params[:source])
	
	respond_with @source_division
  end

  def edit
    @source_division = SourceDivision.includes(:source).find(params[:id])
    @source = @source_division.source

    respond_with @source_division
  end
  
  def create
    source = Source.find(params[:source_division][:source])
	idnum = source.id - source.id
	
	unless params[:source_division][:id].nil?
	  unless params[:source_division][:id] == ""
	    idnum = params[:source_division][:id].to_i
	  end
	end
	
	if idnum > 0
	  idnum = SourceDivision.find(idnum).position
	else
	  div = SourceDivision.where("source_id = ?",source.id).order(:position).last
	  if div.nil?
	    idnum = 0
	  else
	    idnum = div.position + 1
	  end
	end
	
	normalize_unicode_params! params[:source_division], :presentation_before, :presentation_after
	
	ActiveRecord::Base.connection.execute "UPDATE source_divisions SET position = position+1 WHERE position >= #{idnum} AND source_id = #{source.id};"
	@source_division = SourceDivision.new
	@source_division.source = source
	@source_division.position = idnum	
	@source_division.title = params[:source_division][:title]
	@source_division.cached_citation = params[:source_division][:title]
	@source_division.cached_status_tag = "unannotated"
	
	unless params[:source_division][:presentation_before].nil?
	  unless params[:source_division][:presentation_before] == ""
	    @source_division.presentation_before = params[:source_division][:presentation_before]
	  end
	end	
	unless params[:source_division][:presentation_after].nil?
	  unless params[:source_division][:presentation_after] == ""
	    @source_division.presentation_after = params[:source_division][:presentation_after]
	  end
	end
	
	@source_division.save
	respond_with @source_division	
  end

  def update
    normalize_unicode_params! params[:source_division], :presentation_before, :presentation_after

    @source_division = SourceDivision.find(params[:id])
    @source_division.update_attributes(params[:source_division])

    respond_with @source_division
  end
end
