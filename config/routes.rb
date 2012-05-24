ActionController::Routing::Routes.draw do |map|
  map.connect 'mailwrapper_issue_rules/:action', :controller => 'mailwrapper_issue_rules'
  map.connect 'mailwrapper_news_rules/:action',  :controller => 'mailwrapper_news_rules'
  map.connect 'mailwrapper_recipients/:action',  :controller => 'mailwrapper_recipients'
  map.connect 'mailwrapper_senders/:action',     :controller => 'mailwrapper_senders'
  map.connect 'mailwrapper_settings/:action',    :controller => 'mailwrapper_settings'
end

