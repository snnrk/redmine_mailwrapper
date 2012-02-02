class MailwrapperNewsRule < ActiveRecord::Base
  belongs_to :mailwrapper_recipient
  belongs_to :project
  validates_presence_of :project_id, :mailwrapper_recipient_id
  validates_uniqueness_of :project_id, :message => :is_duplicated
end

