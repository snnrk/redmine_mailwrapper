module MailwrapperProjectsHelperPatch
  def self.included base # :nodoc:
    base.send :include, MailwrapperProjectsHelperMethods
    base.class_eval do
      alias_method_chain :project_settings_tabs, :mailwrapper
    end
  end
end

module MailwrapperProjectsHelperMethods
  def project_settings_tabs_with_mailwrapper
    tabs = project_settings_tabs_without_mailwrapper
    action = {
              :name => 'mailwrapper',
              :controller => 'mailwrapper_settings',
              :action => :show,
              :partial => 'mailwrapper_settings/show',
              :label => :mailwrapper
             }
    tabs << action if User.current.allowed_to?(action, @project)
    tabs
  end
end

