import python

from StringLiteral sl
where sl.value contains "password" or sl.value contains "secret" or sl.value contains "token" or sl.value contains "key"
select sl, "Potential CWE-522: Credential stored in clear text"