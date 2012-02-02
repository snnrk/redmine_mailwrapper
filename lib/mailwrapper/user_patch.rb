module MailwrapperUserPatch
  def self.included base
    base.has_and_belongs_to_many :mailwrapper_issue_rules
    base.has_and_belongs_to_many :mailwrapper_recipients
  end
end
