class MailwrapperSender < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :project_id, :sender
  validates_uniqueness_of :project_id, :message => :is_duplicated
end
