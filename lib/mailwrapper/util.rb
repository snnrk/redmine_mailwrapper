require 'logger'

class MailwrapperUtil
  def MailwrapperUtil.is_enabled?(project)
    return false if project.nil?
    project.module_enabled? :mailwrapper
  end
end

