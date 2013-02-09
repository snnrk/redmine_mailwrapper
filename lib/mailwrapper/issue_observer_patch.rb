module MailwrapperIssueObserverPatch
  def self.included base
    base.send :include, MailwrapperIssueObserverMethods
    base.class_eval do
      alias_method_chain :after_create, :mailwrapper
    end
  end
end

module MailwrapperIssueObserverMethods
  def after_create_with_mailwrapper(issue)
    if Setting.notified_events.include?('issue_added')
      mail = Mailer.issue_add(issue)
      MailwrapperUtil.rewrite_issue(mail, issue, issue.author.login)
      mail.deliver
    end
  end
end
