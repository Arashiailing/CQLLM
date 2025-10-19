import python
import dataflow

/**
 * @name URL redirection from remote source
 * @description Detects URL redirection based on unvalidated user input.
 */
predicate isUnvalidatedRedirect(Call call) {
  // Check for common redirect functions in Flask
  call.getTarget() = "redirect" and
  call.getModule().getName() = "flask" and
  // Check if the argument is coming from user input (e.g., request.args.get)
  exists (Call userInputCall, Argument arg |
    userInputCall.getTarget() = "get" and
    userInputCall.getDeclaringClass().getName() = "request" and
    arg = call.getArgs()[0] and
    userInputCall.getModule().getName() = "werkzeug.wrappers.request" and
    arg.getValue() = userInputCall.getArgs()[0].getValue()
  )
}

from Call call
where isUnvalidatedRedirect(call)
select call, "Potential URL redirection with unvalidated user input"