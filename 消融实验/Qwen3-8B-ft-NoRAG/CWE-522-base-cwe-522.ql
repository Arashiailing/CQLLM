import py

from StringLiteral sl
where sl.value matches /password|secret|key|token|credentials/i
select sl, "Found a string literal that may contain cleartext credentials."