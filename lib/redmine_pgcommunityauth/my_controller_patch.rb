module RedminePgcommunityauth
  module MyControllerPatch
    unloadable

    def self.included(base)
      base.class_eval do
        alias_method_chain :password, :pgcommunityauth
      end
    end

    def password_with_pgcommunityauth
      flash[:error] = "Password is managed centrally with Postgres commnunity login."
      redirect_to my_account_path
    end
  end
end
