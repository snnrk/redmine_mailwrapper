module MailwrapperMailerPatch
  def self.included base
	 base.send :include, MailwrapperMailerMethods
	 base.class_eval do
		alias_method_chain :issue_add, :mailwrapper if self.method_defined? :issue_add
		alias_method_chain :issue_edit, :mailwrapper if self.method_defined? :issue_edit
		alias_method_chain :news_added, :mailwrapper if self.method_defined? :news_added
		alias_method_chain :news_comment_added, :mailwrapper if self.method_defined? :news_comment_added
		alias_method_chain :mail, :mailwrapper
	 end
  end
end

module MailwrapperMailerMethods
  ##
  ## for alias_method_chain
  ##
  def issue_add_with_mailwrapper(issue)
	 Rails.logger.info "redmine_mailwrapper: issue_add()."
	 set_flag(issue)
	 issue_add_without_mailwrapper(issue)
  end
  def issue_edit_with_mailwrapper(journal)
	 Rails.logger.info "redmine_mailwrapper: issue_edit()."
	 set_flag(journal)
	 issue_edit_without_mailwrapper(journal)
  end
  def news_added_with_mailwrapper(news)
	 Rails.logger.info "redmine_mailwrapper: news_added()."
	 set_flag(news)
	 news_added_without_mailwrapper(news)
  end
  def news_comment_added_with_mailwrapper(comment)
	 Rails.logger.info "redmine_mailwrapper: news_comment_added()."
	 set_flag(comment)
	 news_comment_added_without_mailwrapper(comment)
  end
  def mail_with_mailwrapper
	 Rails.logger.info "redmine_mailwrapper: mail()"
	 Rails.logger.info "redmine_mailwrapper: parameters: #{@mailwrapperflag.inspect}"
	 unless @mailwrapperflag.nil?
		begin
		  mailwrapper_sender = mailwrapper_get_sender(@mailwrapperflag)
		  Rails.logger.debug "redmine_mailwrapper: from=#{mailwrapper_sender}."
		  from mailwrapper_sender unless mailwrapper_sender.nil?

		  mailwrapper_recipients = mailwrapper_get_recipients(@mailwrapperflag)
		  unless mailwrapper_recipients.nil?
			 @author ||= User.current
			 if @author.pref[:no_self_notified]
				recipients.delete(@author.mail) if recipients
				cc.delete(@author.mail) if cc
			 end

			 if Setting.bcc_recipients?
				bcc([recipients, cc].flatten.compact.uniq)
				recipients []
				cc []
			 end

			 if recipients
				cc([recipients,cc].flatten.compact.uniq)
				recipients []
			 end
			 mailwrapper_recipients.map {|u| u.mail}.each do |r|
				cc.delete(r) if cc
				bcc.delete(r) if bcc
				recipients([recipients, r].flatten.compact.uniq)
			 end
			 notified_users = [recipients, cc].flatten.compact.uniq
			 headers["X-Redmine-Mailwrapper-Version"] = Redmine::Plugin.find(:redmine_mailwrapper).version
			 Rails.logger.info "redmine_mailwrapper: Sending email notification to: #{notified_users.join(', ')}"
			 Rails.logger.debug "redmine_mailwrapper: call super"
			 return self.class.superclass.instance_method(:mail).bind(self).call
		  end
		rescue
		  Rails.logger.info "redmine_mailwrapper: mailwrapper_get_recipients() failed."
		end
	 end
	 Rails.logger.debug "redmine_mailwrapper: call mail_without_mailwrapper."
	 mail_without_mailwrapper
  end

  private
  def mailwrapperflag=val
	 @mailwrapperflag = val
  end

  def set_flag(obj)
	 if obj.instance_of? Issue
		return false unless MailwrapperUtil.is_enabled?(obj.project)
		@mailwrapperflag = { :type => :issue, :project => obj.project_id,
		  :tracker => obj.tracker_id, :category => obj.category_id, :status => obj.status_id, :author => obj.author.login }
	 elsif obj.instance_of? Journal
		issue = obj.journalized
		return false unless MailwrapperUtil.is_enabled?(issue.project)
		@mailwrapperflag = { :type => :issue, :project => issue.project_id,
		  :tracker => issue.tracker_id, :category => issue.category_id, :status => obj.new_value_for('status_id'),
		  :author => obj.user.login }
	 elsif obj.instance_of? News
		return false unless MailwrapperUtil.is_enabled?(obj.project)
		@mailwrapperflag = { :type => :news, :project => obj.project_id }
	 elsif obj.instance_of? Comment
		news = obj.commented
		return false unless MailwrapperUtil.is_enabled?(news.project)
		@mailwrapperflag = { :type => :news, :project => news.project_id }
	 end

  end

  def mailwrapper_get_recipients(flag)
	 return nil if flag.nil?
	 Rails.logger.debug "redmine_mailwrapper: type=#{flag[:type]}"
	 case flag[:type]
	 when :news
		return mailwrapper_get_news_recipient(flag[:project])
	 when :issue
		return mailwrapper_get_issue_recipient(flag)
	 end
	 
	 Rails.logger.debug "redmine_mailwrapper: unknown route."
	 nil
  end
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
  def mailwrapper_get_sender(flag)
	 begin
		Project.find(flag[:project].to_s).mailwrapper_sender.sender.to_s
	 rescue
		Rails.logger.debug "redmine_mailwrapper: mailwrapper_get_sender() failed."
		nil
	 end
  end
end
