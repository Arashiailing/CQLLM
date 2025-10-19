import python

from MethodCall mc, StringLiteral sl
where mc.getMethodName() = "info" and mc.getQualifierType().getName() = "logging.Logger"
   and mc.getArgument(0).getValue() = sl.getString()
   and sl.getValue() matches /(?i)(password|secret|token|key|cred|cert|private key|api key|auth token)/
select mc.getLocation(), "Potential exposure of sensitive information in log output."