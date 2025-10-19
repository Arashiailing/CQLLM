/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @kind problem
 * @problem.severity warning
 * @security-severity 9.1
 * @precision high
 * @id py/jwa
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.JournalWarningAnalysis
import JournalWarningFlow::PathGraph

from JournalWarningFlow::PathNode source, JournalWarningFlow::PathNode sink
where JournalWarningFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Exposure of sensitive information to an unauthorized actor occurs because data flows from a $@.", source.getNode(), "public endpoint"