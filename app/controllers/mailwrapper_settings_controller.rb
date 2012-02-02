class MailwrapperSettingsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def show
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end
end

