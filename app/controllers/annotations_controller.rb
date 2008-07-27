class AnnotationsController < ApplicationController
  before_filter :is_reviewer?, :only => [:flag_as_reviewed, :flag_as_not_reviewed]

  # GET /annotations
  # GET /annotations.xml
  def index
    @sentences = Sentence.search(params.slice(:completion, :source, :book, :chapter,
                                              :sentence_number), params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sentences }
    end
  end

  # GET /annotation/1
  # GET /annotation/1.xml
  def show
    @sentence = Sentence.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sentence }
    end
  end

  def flag_as_reviewed
    @sentence = Sentence.find(params[:id])

    versioned_transaction do
      @sentence.set_reviewed!(User.find(session[:user_id]))
      flash[:notice] = 'Annotation was successfully updated.'
      redirect_to(annotation_path(@sentence))
    end
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = invalid.record.errors.full_messages.join('<br>')
    render :action => "show"
  end

  def flag_as_not_reviewed
    @sentence = Sentence.find(params[:id])

    versioned_transaction do
      @sentence.unset_reviewed!(User.find(session[:user_id]))
      flash[:notice] = 'Annotation was successfully updated.'
      redirect_to(annotation_path(@sentence))
    end
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = invalid.record.errors.full_messages.join('<br>')
    render :action => "show"
  end
end
