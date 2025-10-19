/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/sosreport
 */
import python
import semmle.codeql.dataflow.DataFlow

from Call call, StringLiteral literal
where call.getArgument(0).getValue() = literal
  and literal.getStringValue() = "sosreport"
  and call.getMethodName() = "write"
  and call.getReceiver().getType().getName() = "File"
select call, "Sensitive information (sosreport) is stored in cleartext."