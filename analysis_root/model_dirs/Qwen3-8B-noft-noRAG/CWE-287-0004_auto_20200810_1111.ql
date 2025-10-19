import python

from StringLiteral sl
where sl.getString().matches(".*(?i)(password|secret|token|key|credential|auth|privatekey|certificate|sspi|oauth|api_key|mongodb_uri|mysql_password|postgres_password).*")
select sl, "Potential CWE-287: Sensitive information stored in cleartext."