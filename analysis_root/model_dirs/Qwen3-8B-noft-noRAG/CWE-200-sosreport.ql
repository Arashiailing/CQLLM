import python

/** @predicate */
def is_sensitive_string(str: String) {
  // Match common sensitive patterns like passwords, keys, secrets
  str.matches("^(?i)(password|key|token|secret|cred(entials)?|apikey|auth_token)[^a-z0-9_]*=[^\\n]*")
}

from StringLiteral sl
where is_sensitive_string(sl)
select sl, "Potential exposure of sensitive information in hardcoded string."