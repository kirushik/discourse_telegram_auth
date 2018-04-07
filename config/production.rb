def load_from_env! variable
  ENV[variable] or fail "$#{variable} is not set"
end

config['encryption_key'] = load_from_env! 'DISCOURSE_ENCRYPTION_KEY'
config['discourse_url'] = load_from_env! 'DISCOURSE_URL'

config['telegram_bot'] = load_from_env! 'TELEGRAM_BOT_NAME'
config['telegram_bot_token'] = load_from_env! 'TELEGRAM_BOT_TOKEN'
config['email_domain_stub'] = load_from_env! 'EMAIL_DOMAIN_STUB'
