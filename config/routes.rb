RedmineApp::Application.routes.draw do
  match 'mailwrapper_issue_rules/:action', :controller => 'mailwrapper_issue_rules'
  match 'mailwrapper_news_rules/:action',  :controller => 'mailwrapper_news_rules'
  match 'mailwrapper_recipients/:action',  :controller => 'mailwrapper_recipients'
  match 'mailwrapper_senders/:action',     :controller => 'mailwrapper_senders'
  match 'mailwrapper_settings/:action',    :controller => 'mailwrapper_settings'
end

