module MailwrapperMailerPatch
  def self.included base
    base.send :include, MailwrapperMailerMethods
    base.class_eval do
      alias_method_chain :issue_add, :mailwrapper if self.method_defined? :issue_add
      alias_method_chain :issue_edit, :mailwrapper if self.method_defined? :issue_edit
      alias_method_chain :news_added, :mailwrapper if self.method_defined? :news_added
      alias_method_chain :news_comment_added, :mailwrapper if self.method_defined? :news_comment_added
    end
  end
end

module MailwrapperMailerMethods
  ##
  ## for alias_method_chain
  ##
  def issue_add_with_mailwrapper(issue)
    Rails.logger.info "redmine_mailwrapper: issue_add()."
    mail = issue_add_without_mailwrapper(issue)
    mailwrapper_rewrite_issue(mail, issue, issue.author.login)
  end
  def issue_edit_with_mailwrapper(journal)
    Rails.logger.info "redmine_mailwrapper: issue_edit()."
    mail = issue_edit_without_mailwrapper(journal)
    mailwrapper_rewrite_issue(mail, journal.journalized, journal.user.login)
  end
  def news_added_with_mailwrapper(news)
    Rails.logger.info "redmine_mailwrapper: news_added()."
    mail = news_added_without_mailwrapper(news)
    mailwrapper_rewrite_news(mail, news)
  end
  def news_comment_added_with_mailwrapper(comment)
    Rails.logger.info "redmine_mailwrapper: news_comment_added()."
    mail = news_comment_added_without_mailwrapper(comment)
    mailwrapper_rewrite_news(mail, comment.commented)
  end

  private

  def mailwrapper_get_news_recipient(project)
	 begin
		return Project.find(project.to_s).mailwrapper_news_rule.mailwrapper_recipient.users
	 rescue
		Rails.logger.debug "redmine_mailwrapper: mailwrapper_get_news_recipient failed."
		return nil
	 end
  end
  def mailwrapper_get_issue_recipient(flag)
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
			 Rails.logger.debug "redmine_mailwrapper: mailwrapper_get_issue_recipient failed."
			 return nil
		  end
		end
	 else
		Rails.logger.debug "redmine_mailwrapper: no issue rule."
	 end
	 Rails.logger.debug "redmine_mailwrapper: unknown route."
	 nil
  end
  def mailwrapper_get_sender(prj)
	 begin
		Project.find(prj).mailwrapper_sender.sender.to_s
	 rescue
		Rails.logger.debug "redmine_mailwrapper: mailwrapper_get_sender() failed."
		nil
	 end
  end
  def mailwrapper_rewrite_issue(mail, issue, author)
    if MailwrapperUtil.is_enabled?(issue.project)
      begin
        sender = mailwrapper_get_sender(issue.project.to_s)
        recipients = mailwrapper_get_issue_recipient({
                                                       :project => issue.project_id,
                                                       :tracker => issue.tracker_id,
                                                       :category => issue.category_id,
                                                       :status => issue.status_id,
                                                       :author => author
                                                     })
        mail = mailwrapper_rewrite(mail, sender, recipients)
      rescue
        Rails.logger.info "redmine_mailwrapper: mailwrapper_rewrite_issue() failed."
      end
    end
    return mail
  end
  def mailwrapper_rewrite_news(mail, news)
    if MailwrapperUtil.is_enabled?(news.project)
      begin
        sender = mailwrapper_get_sender(news.project.to_s)
        recipients = mailwrapper_get_news_recipient(news.project.to_s)
      rescue
        Rails.logger.info "redmine_mailwrapper: mailwrapper_rewrite_news() failed."
      end
      mail = mailwrapper_rewrite(mail, sender, recipients)
    end
    return mail
  end
  def mailwrapper_rewrite(mail, sender, recipients)
    Rails.logger.debug "redmine_mailwrapper: call rewrite()"
    mail.headers({ "X-Redmine-Mailwrapper-Version" => Redmine::Plugin.find(:redmine_mailwrapper).version })
    Rails.logger.debug "redmine_mailwrapper: from=#{sender}."
    mail.from = sender unless sender.nil?

    unless recipients.nil?
      @author ||= User.current
      if @author.pref[:no_self_notified]
        recipients.delete(@author.mail) if recipients
        cc.delete(@author.mail) if cc
      end
      
      if mail.to
        mail.cc = [mail.to, mail.cc].flatten.compact.uniq
        mail.to = []
      end
      mailwrapper_recipients.map {|u| u.mail}.each do |r|
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
