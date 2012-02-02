class MailwrapperRecipient < ActiveRecord::Base
  has_many :mailwrapper_issue_rules,         :dependent => :destroy
  has_many :mailwrapper_news_rules,          :dependent => :destroy
  has_and_belongs_to_many :users
  belongs_to :project

  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, :scope => :project_id, :message => :is_duplicated 
  validates_length_of :user_ids, :minimum => 1, :message => :is_blank
end

