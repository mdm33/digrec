class InfoStatusesController < ApplicationController
  before_filter :is_annotator?, :only => [:edit, :update]

  # GET /annotations/1/info_status
  def show
    @sentence = Sentence.find(params[:annotation_id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end


  # GET /annotations/1/info_status/edit
  def edit
    @sentence = Sentence.find(params[:annotation_id])
  end


  # PUT /annotations/1/info_status
  def update
    @sentence = Sentence.find(params[:annotation_id])

    # If we could trust that Hash#keys and Hash#values always return values in the
    # same order, we could simply use params[:tokens].keys and params[:tokens].values as
    # arguments to the ActiveRecord::Base.update method (like in the example in the
    # standard Rails documentation for the method). But can we...?
    ids, attributes = get_ids_and_attributes_from_params
    ids.zip(attributes).each do |id, attr|
      if(id.starts_with?('new'))
        create_prodrop_relation(id, attr)
      else
        Token.find(id).update_attributes!(attr)
      end
    end
  rescue
    render :text => $!, :status => 500
    raise
  else
    render :text => ''
  end


  #########
  protected
  #########

  def get_ids_and_attributes_from_params
    ids_ary = []
    attributes_ary = []

    if params[:tokens]
      params[:tokens].each_pair do |id, category|
        ids_ary << id
        attributes_ary << {:info_status => category.tr('-', '_').to_sym}
      end
    end

    [ids_ary, attributes_ary]
  end

  def create_prodrop_relation(prodrop_id, prodrop_attr)
    prodrop_attr[:info_status].to_s =~ /(.+?);prodrop_(.+?)_token_(\d+)/
    info_status = $1
    relation = $2
    verb_id = $3.to_i

    graph = @sentence.dependency_graph
    verb_node = graph[verb_id]

    verb_token = Token.find(verb_id)
    prodrop_token = @sentence.tokens.create!({
                                               :verse => verb_token.verse,
                                               :token_number => @sentence.max_token_number + 1,
                                               :form => 'PRO-' + relation.upcase,
                                               :relation => relation,
                                               :sort => :prodrop,
                                               :info_status => info_status
                                             })
    adjust_token_numbers(prodrop_token, verb_token, relation)
    prodrop_node = graph.node_class
    graph.add_node(prodrop_token.id, relation, verb_token.id)
    @sentence.syntactic_annotation = graph
  end

  # Moves a new prodrop token to the correct position in the token_number sequence
  def adjust_token_numbers(prodrop_token, verb_token, relation)
    new_token_number = verb_token.token_number + (relation == 'sub' ? 0 : 1)

    # Move all later tokens one step to the right
    @sentence.tokens.reverse.each do |token|
      if token.token_number >= new_token_number
        token.token_number += 1
        token.save!
      else
        break
      end
    end

    # Insert the prodrop token in the correct position
    prodrop_token.token_number = new_token_number
    prodrop_token.save!
  end
end
