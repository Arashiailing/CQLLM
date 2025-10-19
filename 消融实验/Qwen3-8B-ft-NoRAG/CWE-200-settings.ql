import python

from Call
where (Call.getKind() = "logging.info" or Call.getKind() = "logging.debug" or Call.getKind() = "print")
  and (Call.getArgument(0).isStringLiteral() and Call.getArgument(0).getValue().contains("password") or
       Call.getArgument(0).isVar() and Call.getArgument(0).getName().matches("password|secret|key"))
select Call, "Potential exposure of sensitive information in log or output."