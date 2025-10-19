import python

from Call call, StringLiteral str
where (call.getTarget() = logging.info
       or call.getTarget() = logging.warning
       or call.getTarget() = logging.error
       or call.getTarget() = logging.debug
       or call.getTarget() = print
       or call.getTarget() = sys.stderr.write)
  and str in call.getArgs()
  and str.getValue() matches /password|secret|token|key|credentials|api|auth|private|confidential/i
select call, "Potential exposure of sensitive information in log or print statement."