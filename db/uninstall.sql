DROP TABLE mailwrapper_issue_rules;
DROP TABLE mailwrapper_news_rules;
DROP TABLE mailwrapper_recipients;
DROP TABLE mailwrapper_issue_rules_trackers;
DROP TABLE issue_categories_mailwrapper_issue_rules;
DROP TABLE issue_statuses_mailwrapper_issue_rules;
DROP TABLE mailwrapper_issue_rules_users;
DROP TABLE mailwrapper_recipients_users;
DROP TABLE mailwrapper_senders;
DELETE FROM schema_migrations WHERE version like '%-redmine_mailwrapper';
