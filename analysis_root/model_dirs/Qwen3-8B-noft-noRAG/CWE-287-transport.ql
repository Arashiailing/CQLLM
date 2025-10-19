import python

/**
 * Query to detect CWE-287: Improper Authentication related to PAM authorization queries.
 */
from Call call
where call.getCalleeName() = "pam.authenticate" and
      not exists (call.getArgument(0).getValue().getExpression() instanceof Literal) and
      not exists (call.getArgument(1).getValue().getExpression() instanceof Literal)
select call, "Potential improper authentication via missing PAM validation"