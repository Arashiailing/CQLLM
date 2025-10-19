import python

/**
 * This query detects CWE-284: Improper Access Control.
 * It looks for sensitive data being stored in cleartext.
 */

from Call call, DataFlow::Node source, DataFlow::Node sink
where call.getCallee().getName() = "store"
  and call.getArgument(0).getValue() instanceof SensitiveData
  and DataFlow::localFlow(source, sink)
  and sink instanceof StringLiteral
select call, "Sensitive data is being stored in cleartext."