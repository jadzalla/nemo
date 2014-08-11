module Concerns::ApplicationController::Crud
  extend ActiveSupport::Concern

  # attempts to destroy obj and add an i18n'd success message to flash
  # on error, translates the error message and adds that to flash
  def destroy_and_handle_errors(obj, options = {})
    begin
      obj.send(options[:but_first]) if options[:but_first]
      obj.destroy
      flash[:success] = "#{obj.class.model_name.human} #{t('errors.messages.deleted_successfully')}"
    rescue DeletionError
      flash[:error] = t($!.to_s, :scope => [:activerecord, :errors, :models, obj.class.model_name.i18n_key], :default => t("errors.messages.generic_delete_error"))
    end
  end

  # sets a success message based on the given object
  def set_success(obj)
    # get verb (past tense) based on action
    verb = t("common.#{params[:action]}d").downcase

    # build and set the message
    flash[:success] = "#{obj.class.model_name.human.ucwords} #{verb} #{t('common.successfully').downcase}."
  end

  # sets a success message and redirects
  def set_success_and_redirect(obj, options = {})
    # redirect to index_url_with_page_num by default
    options[:to] ||= index_url_with_page_num

    # save the object id in the flash in case the view wants to have some fun with it
    flash[:modified_obj_id] = obj.id

    # if options[:to] is a symbol, we really mean :action => xxx
    options[:to] = {:action => options[:to]} if options[:to].is_a?(Symbol)

    set_success(obj)

    # do the redirect
    redirect_to(options[:to])
  end

  # gets the url to an index action, ensuring the appropriate page is returned to
  # ctlr - the controller whose index should be used. defaults to current controller
  def index_url_with_page_num(ctlr = nil)
    url_for(:controller => ctlr || controller_name, :action => :index, :page => get_last_page_number)
  end

  # remembers the last visited page number for each controller and mission
  def remember_page_number
    if params[:page]
      session[:last_page_numbers] ||= {}
      session[:last_page_numbers][last_page_number_hash_key] = params[:page]
    end
  end

  # builds a simple hash key for remembering page numbers
  def last_page_number_hash_key
    controller_name + current_mission.try(:id).to_s
  end

  def get_last_page_number
    if session[:last_page_numbers]
      session[:last_page_numbers][last_page_number_hash_key]
    else
      nil
    end
  end

  # gets the request's referrer without the query string
  def referrer_without_query_string
    ref = URI(request.referrer)
    ref.to_s.gsub("?#{ref.query}", '')
  end
end
