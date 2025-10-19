import python

from FunctionCall call, ExternalSource externalSource, StringLiteral formatString
where call.getTarget().getName() = "format"
  and call.getArgument(0) = externalSource
  and call.getArgument(1) = formatString
select call, "This function call may be vulnerable to CWE-134: Use of Externally-Controlled Format String."