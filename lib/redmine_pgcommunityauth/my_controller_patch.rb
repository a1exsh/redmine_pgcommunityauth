module RedminePgcommunityauth
  module MyControllerPatch
    unloadable

    def password
      flash[:error] = "Password is managed centrally with Postgres commnunity login."
      redirect_to my_account_path
    end
  end
end
