ActiveSupport::Reloader.to_prepare do
  require_dependency 'redmine_pgcommunityauth/my_controller_patch.rb'
  require_dependency 'redmine_pgcommunityauth/account_controller_patch.rb'
end

Redmine::Plugin.register :redmine_pgcommunityauth do
  name 'Redmine Pgcommunityauth plugin'
  author 'Alex Shulgin <alex.shulgin@gmail.com>'
  description ''
  version '0.4.0'
  requires_redmine :version_or_higher => '4.0.0'

  settings :default => {}, :partial => 'settings/redmine_pgcommunityauth_settings'
end
