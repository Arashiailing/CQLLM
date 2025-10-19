import python

from LogCall log, StringLiteral str
where log.getArgument(0) = str
  and str.getValue() matches /password|secret|key|token|cred|auth|token|private|sensitive/i
select log, "Potential CWE-532: Sensitive information logged in log message."