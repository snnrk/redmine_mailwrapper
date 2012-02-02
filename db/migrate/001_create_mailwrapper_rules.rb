class CreateMailwrapperRules < ActiveRecord::Migration
  def self.up
    create_table :mailwrapper_issue_rules do |t|
      t.column :priority,                 :integer, :null => false
      t.column :project_id,               :integer, :null => false
      t.column :mailwrapper_recipient_id, :integer, :null => false
    end

    create_table :mailwrapper_issue_rules_trackers, :id => false do |t|
      t.column :mailwrapper_issue_rule_id, :integer, :null => false
      t.column :tracker_id,                :integer, :null => false
    end
    add_index :mailwrapper_issue_rules_trackers, :mailwrapper_issue_rule_id, :name => :mailwrapper_issue_rules_trackers_id

    create_table :issue_categories_mailwrapper_issue_rules, :id => false do |t|
      t.column :mailwrapper_issue_rule_id, :integer, :null => false
      t.column :issue_category_id,         :integer, :null => false
    end
    add_index :issue_categories_mailwrapper_issue_rules, :mailwrapper_issue_rule_id, :name => :mailwrapper_issue_rules_issue_categories_id

    create_table :issue_statuses_mailwrapper_issue_rules, :id => false do |t|
      t.column :mailwrapper_issue_rule_id, :integer, :null => false
      t.column :issue_status_id,           :integer, :null => false
    end
    add_index :issue_statuses_mailwrapper_issue_rules, :mailwrapper_issue_rule_id, :name => :mailwrapper_issue_rules_issue_statuses_id

    create_table :mailwrapper_issue_rules_users, :id => false do |t|
      t.column :mailwrapper_issue_rule_id, :integer, :null => false
      t.column :user_id,                   :integer, :null => false
    end
    add_index :mailwrapper_issue_rules_users, :mailwrapper_issue_rule_id, :name => :mailwrapper_issue_rules_users_id

    create_table :mailwrapper_news_rules do |t|
      t.column :project_id,               :integer, :null => false
      t.column :mailwrapper_recipient_id, :integer, :null => false
    end

    create_table :mailwrapper_recipients do |t|
      t.column :project_id,     :integer, :null => false
      t.column :name,           :string,  :null => false
    end

    create_table :mailwrapper_recipients_users, :id => false do |t|
      t.column :mailwrapper_recipient_id, :integer, :null => false
      t.column :user_id,                  :integer, :null => false
    end
    add_index :mailwrapper_recipients_users, :mailwrapper_recipient_id, :name => :mailwrapper_recipients_users_id

  end

  def self.down
    drop_table :mailwrapper_issue_rules
    drop_table :mailwrapper_issue_rules_trackers
    drop_table :issue_categories_mailwrapper_issue_rules
    drop_table :issue_statuses_mailwrapper_issue_rules
    drop_table :mailwrapper_issue_rules_users
    drop_table :mailwrapper_news_rules
    drop_table :mailwrapper_recipients
    drop_table :mailwrapper_recipients_users
  end
end

