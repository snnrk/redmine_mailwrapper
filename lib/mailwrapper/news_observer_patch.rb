module MailwrapperNewsObserverPatch
  def self.included base
    base.send :include, MailwrapperNewsObserverMethods
    base.class_eval do
      alias_method_chain :after_create, :mailwrapper
    end
  end
end

module MailwrapperNewsObserverMethods
  def after_create_with_mailwrapper(news)
    if Setting.notified_events.include?('news_added')
      mail = Mailer.news_added(news)
      MailwrapperUtil.rewrite_news(mail, news)
      mail.deliver
    end
  end
end
