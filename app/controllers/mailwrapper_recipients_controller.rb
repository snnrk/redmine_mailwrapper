class MailwrapperRecipientsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  ##
  ## recipient setting for issue/news rules.
  ##
  def add
    @mailwrapper_recipient = MailwrapperRecipient.new(params[:mailwrapper_recipient])
    if ! (request.get? || request.xhr?)
      if @mailwrapper_recipient.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      end
    end
  end

  def mod
    @mailwrapper_recipient = MailwrapperRecipient.find(params[:id])
    if ! (request.get? || request.xhr?)
      @mailwrapper_recipient.project_id = @project.id
      @mailwrapper_recipient.users.clear if (params[:mailwrapper_recipient][:user_ids].nil? && @mailwrapper_recipient.users.size)
      if @mailwrapper_recipient.update_attributes(params[:mailwrapper_recipient])
        flash[:notice] = l(:notice_successful_update)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      end
    end
    render :layout => !request.xhr?
  end

  def del
    mailwrapper_recipient = MailwrapperRecipient.find(params[:id])
    if mailwrapper_recipient.nil? or ! mailwrapper_recipient.destroy
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

