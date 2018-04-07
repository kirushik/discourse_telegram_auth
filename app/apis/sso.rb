require 'grape'
require 'erb'

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
      content_type 'text/html'
      body TELEGRAM_LOGIN_PAGE.result_with_hash telegram_bot: env.telegram_bot
    end

    get '/telegram_callback' do
      sso = cookies[:sso]
      sig = cookies[:sig]

      #user_data = parse_saml_payload(params[:SAMLResponse], env)

      if user_data
        sign_on = SingleSignOn.parse sso, sig, env.encryption_key

        sign_on.external_id = user_data[:external_id]
        sign_on.username = user_data[:username]
        sign_on.name = user_data[:name]
        sign_on.email = user_data[:email]

        discourse_url = URI.parse env.discourse_url
        discourse_url.path = '/session/sso_login'
        redirect sign_on.to_url discourse_url.to_s
      else
        status 401
      end
    end
  end
end