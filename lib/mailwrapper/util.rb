require 'logger'

class MailwrapperUtil
  def MailwrapperUtil.is_enabled?(project)
    return false if project.nil?
    project.module_enabled? :mailwrapper
  end
  def MailwrapperUtil.get_issue_recipient(flag)
    Rails.logger.debug "redmine_mailwrapper: get_issue_recipient()."
    project = Project.find(flag[:project].to_s)
    unless (project.mailwrapper_issue_rules.empty?)
      project.mailwrapper_issue_rules.each do |r|
        Rails.logger.debug "redmine_mailwrapper: rule_id=#{r.id}"
        next if (! r.trackers.empty? and r.trackers.select {|t| t.id == flag[:tracker]}.empty?)
        Rails.logger.debug "redmine_mailwrapper: tracker mismatch"
        next if (! r.issue_categories.nil? and ! r.issue_categories.empty? and r.issue_categories.select {|c| c.id == flag[:category]}.empty?)
        Rails.logger.debug "redmine_mailwrapper: category mismatch"
        next if (! r.issue_statuses.empty? and r.issue_statuses.select {|s| s.id == flag[:statuses]}.empty?)
        Rails.logger.debug "redmine_mailwrapper: status mismatch"
        next if (! r.users.empty? and r.users.select {|u| u.login == flag[:author]}.empty?)
        Rails.logger.debug "redmine_mailwrapper: user mismatch"
        begin
          return r.mailwrapper_recipient.users
        rescue
          Rails.logger.debug "redmine_mailwrapper: get_issue_recipient failed."
          nil
        end
      end
    else
      Rails.logger.debug "redmine_mailwrapper: no issue rule."
    end
    Rails.logger.debug "redmine_mailwrapper: unknown route."
    nil
  end
  def MailwrapperUtil.get_news_recipient(project)
    begin
      return project.mailwrapper_news_rule.mailwrapper_recipient.users
    rescue
      Rails.logger.debug "redmine_mailwrapper: get_news_recipient failed."
      return nil
    end
  end
  def MailwrapperUtil.get_sender(project)
    Rails.logger.debug "redmine_mailwrapper: get_sender()."
    begin
      project.mailwrapper_sender.sender.to_s
    rescue
      Rails.logger.debug "redmine_mailwrapper: get_sender() failed."
      nil
    end
  end
  def MailwrapperUtil.rewrite_issue(mail, issue, author)
    Rails.logger.debug "redmine_mailwrapper: call rewrite_issue()"
    if MailwrapperUtil.is_enabled?(issue.project)
      begin
        sender = get_sender(issue.project)
        flag = {
          :project => issue.project_id,
          :tracker => issue.tracker_id,
          :category => issue.category_id,
          :status => issue.status_id,
          :author => author
        }
        recipients = get_issue_recipient(flag)
        mail = rewrite(mail, sender, recipients)
      rescue
        Rails.logger.info "redmine_mailwrapper: mailwrapper_rewrite_issue() failed."
      end
    end
    return mail
  end
  def MailwrapperUtil.rewrite_news(mail, news)
    Rails.logger.debug "redmine_mailwrapper: call rewrite_news()"
    if MailwrapperUtil.is_enabled?(news.project)
      begin
        sender = get_sender(news.project)
        recipients = get_news_recipient(news.project)
        mail = rewrite(mail, sender, recipients)
      rescue
        Rails.logger.info "redmine_mailwrapper: mailwrapper_rewrite_news() failed."
      end
    end
    return mail
  end
  def MailwrapperUtil.rewrite(mail, sender, recipients)
    Rails.logger.debug "redmine_mailwrapper: call rewrite()"
    mail.headers("X-Redmine-Mailwrapper-Version" => Redmine::Plugin.find(:redmine_mailwrapper).version)
    mail.from = sender unless sender.nil?
    unless recipients.nil?
      if mail.to
        mail.cc = [mail.to, mail.cc].flatten.compact.uniq
        mail.to = []
      end
      recipients.map {|u| u.mail}.each do |r|
        mail.cc.delete(r) if mail.cc
        mail.bcc.delete(r) if mail.bcc
        mail.to = [mail.to, r].flatten.compact.uniq
      end
      notified_users = [mail.to, mail.cc].flatten.compact.uniq
      Rails.logger.info "redmine_mailwrapper: Sending email notification to: #{notified_users.join(', ')}"
      return mail
    end
  end
end

