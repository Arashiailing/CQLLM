import python

from ConfigFileValue cfg
where cfg.file.path matches ".*\.(env|conf|ini|cfg|yml|json)" and
      (cfg.key contains "password" or cfg.key contains "secret" or cfg.key contains "token") and
      cfg.value matches "^[a-zA-Z0-9]{8,}$"
select cfg, "Found sensitive credential in config file."

from EnvironmentVariable env
where env.name matches "API_KEY|DB_PASSWORD|SECRET_KEY|JWT_SECRET|OAUTH_TOKEN" and
      env.value matches "^[a-zA-Z0-9]{8,}$"
select env, "Found sensitive environment variable."

from LogMessage log
where log.message matches "password: [a-zA-Z0-9]{8,}" or
      log.message matches "secret: [a-zA-Z0-9]{8,}" or
      log.message matches "token: [a-zA-Z0-9]{8,}"
select log, "Found sensitive info in log."

from Assignment assign
where assign.variable.name matches "password|secret|token|api_key|auth_token" and
      assign.value matches "^[a-zA-Z0-9]{8,}$"
select assign, "Hardcoded sensitive value."