#--
#
# Copyright 2007, 2008, 2009, 2010, 2011, 2012, 2013 University of Oslo
# Copyright 2007, 2008, 2009, 2010, 2011, 2012, 2013 Marius L. Jøhndal
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

class AuditsController < ApplicationController
  append_view_path AuditsResolver.new
  respond_to :html, :xml
  before_filter :is_annotator?
  before_filter :is_administrator?, :only => [:destroy]

  def index
    if params[:sentence_id]
      # Grab changes related to this sentence, i.e. the object itself and
      # its tokens.

      @sentence = Sentence.find(params[:sentence_id])
      @tokens = @sentence.tokens.includes(:lemma)

      objs = []
      objs << [Sentence, [@sentence]]
      objs << [Token, @tokens]
      s = objs.map { |k, v| "(auditable_type = '#{k}' AND auditable_id IN (?))" }.join(' OR ')
      v = objs.map { |k, v| v }

      @audits = Audited::Adapters::ActiveRecord::Audit.where(s, *v).page(current_page)
    elsif params[:user_id]
      # Grab changes by this user.
      @user = User.find(params[:user_id])
      @audits = @user.audits.page(current_page)
    else
      @audits = Audited::Adapters::ActiveRecord::Audit.page(current_page)
    end

    respond_with @audits
  end

  def show
    @audit = Audited::Adapters::ActiveRecord::Audit.find(params[:id])

    respond_with @audit
  end

  def destroy
    @audit = Audited::Adapters::ActiveRecord::Audit.find(params[:id])

    if @audit.auditable.audits.last == @audit
      o = @audit.auditable.revision(:previous)

      if o.valid?
        o.without_auditing { o.save! }
        destroy!
        flash[:notice] = 'Change was successfully reverted'
      else
        flash[:error] = 'Unable to revert: resulting object state is invalid'
      end
    else
      flash[:error] = "Object has been modified after this revision"
    end
  end
end
