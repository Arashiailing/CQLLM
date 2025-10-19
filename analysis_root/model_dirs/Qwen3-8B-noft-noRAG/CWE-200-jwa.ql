import python

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects potential exposure of sensitive information through logging, printing, or error messages.
 */
from Call call, StringLiteral sl
where (call.getTarget() = "print" or 
       call.getTarget() = "logging.Logger.info" or 
       call.getTarget() = "logging.getLogger".get("info") or 
       call.getTarget() = "traceback.print_exception" or 
       call.getTarget() = "sys.stderr.write")
  and call.getArguments().has(sl)
  and sl.getValue().matchesRegexp(
    r"(?i)(password|secret|key|token|api_key|credential|db_password|private_key|oauth_token|session_token|webhook_secret)")
select call, "Potential exposure of sensitive information in output."