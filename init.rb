Rails.application.config.after_initialize do
  AccountController.send(:include, RedminePgcommunityauth::AccountControllerPatch)
end

Redmine::Plugin.register :redmine_pgcommunityauth do
  name 'Redmine Pgcommunityauth plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
  description ''
  version '0.1.0'
  requires_redmine '3.0.0'

  settings :default => {}, :partial => 'settings/redmine_pgcommunityauth_settings'
end
