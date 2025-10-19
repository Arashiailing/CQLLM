/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detection of cleartext logging of sensitive information, which may reveal confidential data to unauthorized parties.
 * @id py/cleartext-logging
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-312
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "$@ produces cleartext log output", source.getNode(),
  "Sensitive data"