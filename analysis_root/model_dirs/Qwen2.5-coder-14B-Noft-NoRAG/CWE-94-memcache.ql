import python

/**
 * CWE-94: Code Injection
 * This query detects instances where user input is interpreted as code.
 */
from Call call, StringLiteral literal
where call.getCallee().getName() = "eval" and
      call.getArgument(0) = literal and
      literal.getValue().matches("%.*")
select call, "The use of eval with unsanitized user input can lead to code injection."