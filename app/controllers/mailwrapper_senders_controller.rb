class MailwrapperSendersController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  ##
  ## sender setting for mailwrapper
  ##
  def add
    @mailwrapper_sender = MailwrapperSender.new(params[:mailwrapper_sender])
    if ! (request.get? || request.xhr?)
      if ! @mailwrapper_sender.sender.empty? && @mailwrapper_sender.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      else
        flash.now[:error] = l(:gui_validation_error)
      end
    end
  end

  def mod
    @mailwrapper_sender = MailwrapperSender.find(params[:sender_id])
    if ! (request.get? || request.xhr?)
      if @mailwrapper_sender.update_attributes(params[:mailwrapper_sender])
        flash[:notice] = l(:notice_successful_update)
        redirect_to({ :controller => 'projects', :action => 'settings', :id => @project, :tab => 'mailwrapper' })
        return
      else
        flash.now[:error] = l(:gui_validation_error)
      end
    end
    render :layout => !request.xhr?
  end

  def del
    mailwrapper_sender = MailwrapperSender.find(params[:sender_id])
    if mailwrapper_sender.nil? or ! mailwrapper_sender.destroy
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

