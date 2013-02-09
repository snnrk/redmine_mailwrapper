module MailwrapperJournalObserverPatch
  def self.included base
    base.send :include, MailwrapperJournalObserverMethods
    base.class_eval do
      alias_method_chain :after_create, :mailwrapper
    end
  end
end

module MailwrapperJournalObserverMethods
  def after_create_with_mailwrapper(journal)
    if journal.notify? &&
        (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
        )
      mail = Mailer.issue_edit(journal)
      MailwrapperUtil.rewrite_issue(mail, journal.journalized, journal.user.login)
      mail.deliver
    end
  end
end
