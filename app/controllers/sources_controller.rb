#--
#
# Copyright 2007-2012 University of Oslo
# Copyright 2007-2016 Marius L. Jøhndal
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

class SourcesController < ApplicationController
  respond_to :html, :xml
  before_action :is_administrator?, :only => [:create, :new, :edit, :update]

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @sources = Source.order(:id).page(current_page).per(90)

    respond_with @sources
  end

  def show
    @source = Source.includes(:source_divisions).find(params[:id])
    @source_divisions = @source.source_divisions.order(:position).page(current_page).per(300)

    sentences = @source.sentences
    @activity_stats = sentences.annotated.where('annotated_at IS NOT NULL').group("DATE_FORMAT(annotated_at, '%Y-%m-%d')").order('annotated_at DESC').limit(10).count
    @sentence_completion_stats = @source.aggregated_status_statistics
    @annotated_by_stats = sentences.annotated.where('annotated_by IS NOT NULL').group(:annotated_by).count.map { |k, v| [User.where(id: k).first.try(:full_name), v] }
    @reviewed_by_stats = sentences.reviewed.where('reviewed_by IS NOT NULL').group(:reviewed_by).count.map { |k, v| [User.where(id: k).first.try(:full_name), v] }

    respond_with @source
  end

  def new
    @source = Source.new

    respond_with @source
  end

  def edit
    @source = Source.find(params[:id])

    respond_with @source
  end
  
  def create
    sourcenum = 0
	unless params[:source][:id].nil?
	  unless params[:source][:id] == ''
	    sourcenum = params[:source][:id].to_i
	  end
	end
	
	if sourcenum <= 0
	  @source = Source.new
	else
	  t = Source.last.id
	  while t >= sourcenum
	    ActiveRecord::Base.connection.execute "UPDATE sources SET id = id+1 WHERE id = #{t};"
	    t -= 1
	  end
	  ActiveRecord::Base.connection.execute "UPDATE source_divisions SET source_id = source_id+1 WHERE source_id >= #{sourcenum};"
	  ActiveRecord::Base.connection.execute "INSERT INTO sources SET id = #{sourcenum}, code = '';"
	  @source = Source.find(sourcenum)
	end
	
	normalize_unicode_params! params[:source], :author, :title
	
	@source.code = params[:source][:code]
	@source.citation_part = params[:source][:citation_part]
	@source.language_tag = params[:source][:language_tag]
	@source.author = params[:source][:author]
	@source.title = params[:source][:title]
	@source.electronic_text_original_url = params[:source][:electronic_text_original_url]
	@source.printed_text_date = params[:source][:printed_text_date]
	@source.save
	
	respond_with @source
  end

  def update
    normalize_unicode_params! params[:source], :author

    @source = Source.find(params[:id])
	params[:source].delete_if {|key, value| value == "" }
    @source.update_attributes(params[:source])

    respond_with @source
  end
end
