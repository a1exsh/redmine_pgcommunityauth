require 'base64'
require 'openssl' # aes gem doesn't let us disable PKCS#5 padding

module RedminePgcommunityauth
  module AccountControllerPatch
    unloadable

    # GET /pgcommunityauth
    def pgcommunityauth
      data = (params[:d] || "").tr('-_', '+/')
      iv   = (params[:i] || "").tr('-_', '+/')

      begin
        qs = aes_decrypt(data, iv).rstrip
      rescue
        flash[:error] = "Invalid PG communityauth message received."
        raise
      end

      auth = Rack::Utils.parse_query(qs)

      # check auth hash for mandatory keys
      auth_keys = auth.keys
      if %w(t u f l e).any?{ |x| !auth_keys.include?(x) }
        flash[:error] = "Invalid PG communityauth data received."
        raise
      end

      # check auth token timestamp
      if (auth['t'] || 0).to_i < Time.now.to_i - 10
        flash[:error] = "PG community auth token expired."
        raise
      end

      # prepare attrs for create or update
      attrs = {
        :firstname => auth['f'],
        :lastname => auth['l'],
        :mail => auth['e']
      }
      if user = User.find_by_login(auth['u'])
        user.update_attributes! attrs
      else
        user = User.new(attrs)
        # can't pass protected attr in new/create
        user.login = auth['u']
        user.save!
      end

      params[:back_url] = auth['su'] || pgcommunityauth_settings[:default_url]
      successful_authentication(user)
    rescue
      # render default template
    end

    private

    def aes_decrypt(data, iv)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt

      # this is the key point here, otherwise we could use
      # AES.decrypt()
      cipher.padding = 0

      cipher.key = Base64.decode64(pgcommunityauth_settings[:cipher_key])
      cipher.iv  = Base64.decode64(iv)
      cipher.update(Base64.decode64(data)) + cipher.final
    end
  end
end
