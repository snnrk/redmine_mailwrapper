module MailwrapperProjectPatch
  def self.included base
    base.has_many :mailwrapper_issue_rules, :order => 'priority', :dependent => :destroy
    base.has_one :mailwrapper_news_rule,  :dependent => :destroy
    base.has_many :mailwrapper_recipients,  :dependent => :destroy
    base.has_one :mailwrapper_sender,  :dependent => :destroy
  end
end
