import python

from Call import Call
where Call.getTarget().getName() in ("logging.info", "logging.debug", "logging.warning", "logging.error", "logging.critical", "print")
and Call.getArgs().any(arg | arg.getLiteral() is not null and arg.getLiteral().matches(".*password.*|.*secret.*|.*token.*|.*key.*|.*credentials.*|.*API.*"))
select Call, "This call logs sensitive information in the log message."