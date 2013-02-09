module MailwrapperCommentObserverPatch
  def self.included base
    base.send :include, MailwrapperCommentObserverMethods
    base.class_eval do
      alias_method_chain :after_create, :mailwrapper
    end
  end
end

module MailwrapperCommentObserverMethods
  def after_create_with_mailwrapper(comment)
    if comment.commented.is_a?(News) && Setting.notified_events.include?('news_comment_added')
      mail = Mailer.news_comment_added(comment)
      MailwrapperUtil.rewrite_news(mail, comment.commented)
      mail.deliver
    end
  end
end
