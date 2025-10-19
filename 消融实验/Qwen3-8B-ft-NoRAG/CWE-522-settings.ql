import python

from StringLiteral sl
where sl.getValue() matches /password|secret|key|token/i
select sl, "Hardcoded credential in string literal"

from IniFile ini, Section section, Key key
where ini has section section
  and section has key key
  and key.getKeyName() matches /password|secret|key|token/i
  and key.getValue() is not null
select key, "Credential stored in INI file as plain text"

from CallExpr ce
where ce.getCallee() = "hashlib.md5" or ce.getCallee() = "hashlib.sha1"
select ce, "Use of insecure hashing algorithm for password storage"