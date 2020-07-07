require 'base64'
require 'openssl' # aes gem doesn't let us disable PKCS#5 padding

module RedminePgcommunityauth
  module AccountControllerPatch
    unloadable

    class AuthTokenExpiredError < RuntimeError; end
    class InvalidAuthTokenError < RuntimeError; end

    def login
      url = pgcommunityauth_login_url

      back_url = params[:back_url]
      if back_url.present?
        url += "?d=" + encrypt_login_data(back_url)
      end

      redirect_to url
    end

    def logout
      logout_user
      redirect_to pgcommunityauth_logout_url
    end

    # GET /pgcommunityauth
    def pgcommunityauth
      if params[:s] == 'logout'
        flash[:notice] = "Successfully logged out from PG community sites."
        return
      end

      iv   = Base64.urlsafe_decode64(params[:i] || "")
      data = Base64.urlsafe_decode64(params[:d] || "")

      qs = aes_decrypt(pgcommunityauth_cipher_key, iv, data).rstrip
      auth = Rack::Utils.parse_query(qs)

      # check auth hash for mandatory keys
      raise InvalidAuthTokenError.new unless %w(t u f l e).all?{ |x| auth.keys.include?(x) }

      # check auth token timestamp: issued 10 seconds ago or less
      raise AuthTokenExpiredError.new unless Time.now.to_i <= auth['t'].to_i + 10

      user = User.find_by_login(auth['u']) || User.new
      user.login = auth['u']
      user.firstname = auth['f']
      user.lastname = auth['l']
      user.mail = auth['e']
      user.save!

      login_data = auth['d']
      if login_data.present?
        decoded_qs = decrypt_login_data(login_data)
        decoded_data = Rack::Utils.parse_query(decoded_qs)
        params[:back_url] = decoded_data['r']
      else
        params[:back_url] = pgcommunityauth_settings[:default_url]
      end

      successful_authentication(user)
    rescue OpenSSL::Cipher::CipherError
      flash[:error] = "Invalid PG communityauth message received."
    rescue InvalidAuthTokenError
      flash[:error] = "Invalid PG communityauth token received."
    rescue AuthTokenExpiredError
      flash[:error] = "PG community auth token expired."
    end

    private

    def pgcommunityauth_settings
      Setting['plugin_redmine_pgcommunityauth']
    end

    def pgcommunityauth_base_url
      "https://www.postgresql.org/account/auth/#{pgcommunityauth_settings[:authsite_id]}"
    end

    def pgcommunityauth_login_url
      "#{pgcommunityauth_base_url}/"
    end

    def pgcommunityauth_logout_url
      "#{pgcommunityauth_base_url}/logout/"
    end

    def pgcommunityauth_cipher_key
      Base64.decode64(pgcommunityauth_settings[:cipher_key])
    end

    def aes_cipher(key_size)
      #
      # Use OpenSSL to set the padding, otherwise we could use AES.decrypt():
      #
      OpenSSL::Cipher.new("AES-#{key_size*8}-CBC")
    end

    def aes_encrypt(key, iv, data)
      cipher = aes_cipher(key.size)
      cipher.encrypt

      cipher.padding = 0
      cipher.key     = key
      cipher.iv      = iv
      cipher.update(data) + cipher.final
    end

    def aes_decrypt(key, iv, data)
      cipher = aes_cipher(key.size)
      cipher.decrypt

      cipher.padding = 0
      cipher.key     = key
      cipher.iv      = iv
      cipher.update(data) + cipher.final
    end

    def login_data_cipher_key
      # TODO: haven't found a away to use the Rails' secret key base or token
      pgcommunityauth_cipher_key
    end

    def encrypt_login_data(back_url)
      block_length = 16
      iv = OpenSSL::Random.random_bytes(block_length)

      # TODO: why do we include time, if we already have a random salt in IV?
      data = "t=#{Time.now.to_i}&r=#{CGI.escape(back_url)}"

      padded_data = right_pad_to_block_length(data, block_length)
      cipher = aes_encrypt(login_data_cipher_key, iv, padded_data)

      "#{Base64.urlsafe_encode64(iv)}$#{Base64.urlsafe_encode64(cipher)}"
    end

    def right_pad_to_block_length(data, blen)
      data + ' '*(blen - data.size % blen)
    end

    def decrypt_login_data(data)
      parts  = data.split('$')
      iv     = Base64.urlsafe_decode64(parts[0])
      cipher = Base64.urlsafe_decode64(parts[1])

      aes_decrypt(login_data_cipher_key, iv, cipher).rstrip
    end
  end
end

# use prepend to override existing methods:
AccountController.send(:prepend, RedminePgcommunityauth::AccountControllerPatch)
