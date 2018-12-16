Rails.application.config.after_initialize do
  User.send(:include, RedminePgcommunityauth::UserPatch)
  MyController.send(:include, RedminePgcommunityauth::MyControllerPatch)
  AccountController.send(:include, RedminePgcommunityauth::AccountControllerPatch)
end

Redmine::Plugin.register :redmine_pgcommunityauth do
  name 'Redmine Pgcommunityauth plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
  description ''
  version '0.1.0'
  requires_redmine '2.5.2'

  settings :default => {}, :partial => 'settings/redmine_pgcommunityauth_settings'
end
