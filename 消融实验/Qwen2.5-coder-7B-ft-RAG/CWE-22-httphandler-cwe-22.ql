/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/httphandler-cwe-22
 */

import python
import semmle.python.security.dataflow.HttpResponseSplittingQuery
import HttpResponseSplittingFlow::PathGraph

from HttpResponseSplittingFlow::PathNode source, HttpResponseSplittingFlow::PathNode sink
where HttpResponseSplittingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP response depends on a $@.", source.getNode(),
  "user-provided value"