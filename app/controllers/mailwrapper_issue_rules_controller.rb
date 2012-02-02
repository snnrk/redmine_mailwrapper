class MailwrapperIssueRulesController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def add
    @mailwrapper_issue_rule = MailwrapperIssueRule.new(params[:mailwrapper_issue_rule])
    if ! (request.get? || request.xhr?)
      @mailwrapper_issue_rule.project_id = @project.id
      if @mailwrapper_issue_rule.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      end
    end
    render :layout => !request.xhr?
  end
  
  def mod
    @mailwrapper_issue_rule = MailwrapperIssueRule.find(params[:issue_rule_id])
    if ! (request.get? || request.xhr?)
      param = params[:mailwrapper_issue_rule]
      @mailwrapper_issue_rule.issue_categories.clear if (param[:issue_category_ids].nil? && @mailwrapper_issue_rule.issue_categories.size)
      @mailwrapper_issue_rule.issue_statuses.clear if (param[:issue_status_ids].nil? && @mailwrapper_issue_rule.issue_statuses.size)
      @mailwrapper_issue_rule.trackers.clear if (param[:tracker_ids].nil? && @mailwrapper_issue_rule.trackers.size)
      @mailwrapper_issue_rule.users.clear if (param[:user_ids].nil? && @mailwrapper_issue_rule.users.size)
      if @mailwrapper_issue_rule.update_attributes(param)
        flash[:notice] = l(:notice_successful_update)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      end
    end
    render :layout => !request.xhr?
  end

  def mov
    @mailwrapper_issue_rule = MailwrapperIssueRule.find(params[:issue_rule_id])
    case params[:position]
      when 'highest'
        @mailwrapper_issue_rule.move_to_top
      when 'higher'
        @mailwrapper_issue_rule.move_higher
      when 'lower'
        @mailwrapper_issue_rule.move_lower
      when 'lowest'
        @mailwrapper_issue_rule.move_to_bottom
    end if params[:position]
    redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
  end

  def del
    mailwrapper_issue_rule = MailwrapperIssueRule.find(params[:issue_rule_id])
    if mailwrapper_issue_rule.nil? or ! mailwrapper_issue_rule.destroy
      flash.now[:error] = l(:gui_validation_error)
    else
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
    return
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end
end

