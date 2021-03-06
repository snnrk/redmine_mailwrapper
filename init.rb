require 'redmine'
require 'mailwrapper'

Rails.configuration.to_prepare do
  require_dependency 'project'
  unless Project.included_modules.include? MailwrapperProjectPatch
    Project.send(:include, MailwrapperProjectPatch)
  end

  require_dependency 'projects_helper'
  unless ProjectsHelper.included_modules.include? MailwrapperProjectsHelperPatch
    ProjectsHelper.send(:include, MailwrapperProjectsHelperPatch)
  end

  require_dependency 'issue_category'
  unless IssueCategory.included_modules.include? MailwrapperIssueCategoryPatch
    IssueCategory.send(:include, MailwrapperIssueCategoryPatch) 
  end

  require_dependency 'issue_status'
  unless IssueStatus.included_modules.include? MailwrapperIssueStatusPatch
  IssueStatus.send(:include, MailwrapperIssueStatusPatch) 
  end

  require_dependency 'tracker'
  unless Tracker.included_modules.include? MailwrapperTrackerPatch
    Tracker.send(:include, MailwrapperTrackerPatch)
  end

  require_dependency 'user'
  unless User.included_modules.include? MailwrapperUserPatch
    User.send(:include, MailwrapperUserPatch)
  end

  require_dependency 'issue_observer'
  unless IssueObserver.included_modules.include? MailwrapperIssueObserverPatch
    IssueObserver.send(:include, MailwrapperIssueObserverPatch)
  end

  require_dependency 'journal_observer'
  unless JournalObserver.included_modules.include? MailwrapperJournalObserverPatch
    JournalObserver.send(:include, MailwrapperJournalObserverPatch)
  end

  require_dependency 'news_observer'
  unless NewsObserver.included_modules.include? MailwrapperNewsObserverPatch
    NewsObserver.send(:include, MailwrapperNewsObserverPatch)
  end

  require_dependency 'comment_observer'
  unless CommentObserver.included_modules.include? MailwrapperCommentObserverPatch
    CommentObserver.send(:include, MailwrapperCommentObserverPatch)
  end
end


Redmine::Plugin.register :redmine_mailwrapper do
  name 'Redmine mailwrapper plugin'
  author 'OSANAI Noriaki'
  description 'Plugin for Redmine to rewrite mail according to rules for each projects.'
  version '0.1.2'
  requires_redmine :version_or_higher => '2.0.2'

  project_module :mailwrapper do
    permission :manage_mailwrapper,
               :mailwrapper_settings    => [:show],
               :mailwrapper_issue_rules => [:add, :del, :mod, :mov],
               :mailwrapper_news_rules  => [:add, :del, :mod],
               :mailwrapper_recipients  => [:add, :del, :mod],
               :mailwrapper_senders     => [:add, :del, :mod],
               :require => :member
    permission :view_mailwrapper, :mailwrapper_settings => :show, :require => :member
  end
end
