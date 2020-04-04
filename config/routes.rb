RedmineApp::Application.routes.draw do
  get 'pgcommunityauth', :to => 'account#pgcommunityauth'
end
