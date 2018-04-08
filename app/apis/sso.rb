require 'grape'
require 'erb'
require 'openssl'

require './lib/single_sign_on'

module API
  class SSO < Grape::API
    TELEGRAM_LOGIN_PAGE = ERB.new File.read('templates/login.erb.html')

    format :txt

    params do
      requires :sso, type: String
      requires :sig, type: String
    end
    get '/login' do
      cookies[:sso] = declared(params)[:sso]
      cookies[:sig] = declared(params)[:sig]

      content_type 'text/html'
      body TELEGRAM_LOGIN_PAGE.result_with_hash telegram_bot: env.telegram_bot
    end

    params do
      requires :hash, type: String

      requires :id, type: Integer
      requires :username, type: String

      optional :first_name, type: String
      optional :last_name, type: String
      optional :photo_url, type: String
      optional :auth_date, type: String
    end
    get '/telegram_callback' do
      prm = declared(params).symbolize_keys
      secure_string = "auth_date=%{auth_date}\nfirst_name=%{first_name}\nid=%{id}\nlast_name=%{last_name}\nphoto_url=%{photo_url}\nusername=%{username}" % prm
      hmac_secret = OpenSSL::Digest::SHA256.digest(env.telegram_bot_token)
      expected_hmac = OpenSSL::HMAC.hexdigest('sha256', hmac_secret, secure_string)
      raise "HMAC verification failed" unless expected_hmac == prm[:hash]

      sso = cookies[:sso]
      sig = cookies[:sig]

      sign_on = SingleSignOn.parse sso, sig, env.encryption_key

      sign_on.external_id = prm[:id]
      sign_on.username = prm[:username]
      sign_on.email = "#{prm[:username]}@#{env.email_domain_stub}"

      sign_on.name = "%{first_name} %{last_name}" % prm if prm[:first_name] || prm[:last_name]
      sign_on.avatar_url = prm[:photo_url] if prm[:photo_url]

      discourse_url = URI.parse env.discourse_url
      discourse_url.path = '/session/sso_login'
      redirect sign_on.to_url discourse_url.to_s
    end
  end
end