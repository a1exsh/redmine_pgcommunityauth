module RedminePgcommunityauth
  module ApplicationControllerPatch
    unloadable

    def self.included(base)
      base.class_eval do
        alias_method_chain :require_login, :pgcommunityauth
      end
    end

    def require_login_with_pgcommunityauth
      if User.current.logged?
        require_login_without_pgcommunityauth
      else
        respond_to do |format|
          format.html { redirect_to pgcommunityauth_url }
        end
      end
    end

    protected

    def pgcommunityauth_settings
      Setting['plugin_redmine_pgcommunityauth']
    end

    private

    def pgcommunityauth_url
      "https://www.postgresql.org/account/auth/#{pgcommunityauth_settings[:authsite_id]}/"
    end
  end
end
