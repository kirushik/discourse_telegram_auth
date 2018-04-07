require 'grape'

require './lib/single_sign_on'

module API
  class SSO < Grape::API
    format :txt

    params do
      requires :sso, type: String
      requires :sig, type: String
    end
    get '/login' do
      content_type 'text/html'
      body DATA.read
    end

    post '/telegram_callback' do
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

__END__
<html>
  <head>
  </head>
  <body>
    
    <script async src="https://telegram.org/js/telegram-widget.js?4" 
            data-telegram-login="SimpleAuthBot" 
            data-size="large" 
            data-onauth="simpleTelegramAuth(user)" 
            data-request-access="write">
    </script>
    
    <!--     
        1. Проверить есть ли такой пользователь в БД
            - если есть - авторизовать
            - если нет - открыть телеграм бота и попросить ввести email
        2. Реализация через редирект на сайт, а оттуда вызывать бота  -->
    
    <!-- <script type="text/javascript">
      
      function onTelegramAuth(user) { 
        window.open("https://api.telegram.org/bot531048629:AAE2r1K5L1FQQBJZpZV7TEi8FFtg7fQ25xg/sendMessage?chat_id=" 
                + user.id + "&text=Привет " 
                + user.first_name + " " 
                + user.last_name + " c хешом: "
                + user.hash + ". Пожалуйста, сообщи свой емейл, он необходим для регистрации. Дата: "
                + user.auth_date); 
      }  
    </script> -->

    <p id="id"></p>
    <p id="userFisrtName"></p>
    <p id="username"></p>
    <p id="email"></p>

    <script>
        function simpleTelegramAuth(user) {
          document.getElementById("id").innerHTML = user.id.toString();
          document.getElementById("userFisrtName").innerHTML = String(user.first_name);
          document.getElementById("username").innerHTML = String(user.username);
          document.getElementById("email").innerHTML = String(user.username) + "@distributed.earth";
        }
    </script>
  </body>
</html>⏎  
