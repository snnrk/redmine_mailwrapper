class MailwrapperIssueRule < ActiveRecord::Base
  has_and_belongs_to_many :trackers, :order => "#{Tracker.table_name}.position"
  has_and_belongs_to_many :issue_categories
  has_and_belongs_to_many :issue_statuses
  has_and_belongs_to_many :users

  belongs_to :project
  belongs_to :mailwrapper_recipient

  validates_presence_of :project_id, :mailwrapper_recipient_id

  acts_as_list :column=> :priority
end

