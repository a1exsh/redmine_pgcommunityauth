Rails.application.config.after_initialize do
  MyController.prepend(RedminePgcommunityauth::MyControllerPatch)
  AccountController.prepend(RedminePgcommunityauth::AccountControllerPatch)
end

Redmine::Plugin.register :redmine_pgcommunityauth do
  name 'Redmine Pgcommunityauth plugin'
  author 'Alex Shulgin <alex.shulgin@gmail.com>'
  description ''
  version '0.4.0'
  requires_redmine :version_or_higher => '4.0.0'

  settings :default => {}, :partial => 'settings/redmine_pgcommunityauth_settings'
end
