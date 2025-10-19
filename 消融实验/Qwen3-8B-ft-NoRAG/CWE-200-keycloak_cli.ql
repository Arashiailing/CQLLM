import python

from StringLiteral sl
where sl.getValue() matches /password|secret|key|token|credentials|privateKey|cert|certificate|apikey|token|auth|session|cookie|sessionid|username|password|passphrase|otp|sms|email|sms|phone|mobile|contact|login|auth|credentials|apikey|token|bearer|oauth|token|refresh|access|id|client|clientid|clientsecret|password|secret|key|token|credentials|privateKey|cert|certificate/i
select sl, "Potential exposure of sensitive information in string literal."