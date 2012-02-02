module MailwrapperIssueStatusPatch
  def self.included base
    base.has_and_belongs_to_many :mailwrapper_issue_rules
  end
end
