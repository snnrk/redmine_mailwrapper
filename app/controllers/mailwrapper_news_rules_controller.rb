class MailwrapperNewsRulesController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def add
    @mailwrapper_news_rule = MailwrapperNewsRule.new(params[:mailwrapper_news_rule])
 
    if ! (request.get? || request.xhr?)
      if @mailwrapper_news_rule.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      end
    end
    render :layout => !request.xhr?
  end

  def mod
    @mailwrapper_news_rule = MailwrapperNewsRule.find(params[:news_rule_id])
    if ! (request.get? || request.xhr?)
      if @mailwrapper_news_rule.update_attributes(params[:mailwrapper_news_rule])
        flash[:notice] = l(:notice_successful_update)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      end
    end
    render :layout => !request.xhr?
  end

  def del
    mailwrapper_news_rule = MailwrapperNewsRule.find(params[:news_rule_id])
    if mailwrapper_news_rule.nil? or ! mailwrapper_news_rule.destroy
      flash.now[:error] = l(:gui_validation_error)
    else
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
    return
  end

  def show
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end
end

