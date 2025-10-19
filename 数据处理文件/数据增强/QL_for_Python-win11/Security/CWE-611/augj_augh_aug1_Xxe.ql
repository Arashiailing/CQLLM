// @name XML external entity expansion vulnerability
// @description Detects unsafe XML parsing where untrusted input flows
//              into XML processors without XXE protection mechanisms.
// @kind path-problem
// @problem.severity error
// @security-severity 9.1
// @precision high
// @id py/xxe
// @tags security
//       external/cwe/cwe-611
//       external/cwe/cwe-827

// Import core Python analysis libraries
import python

// Import XXE-specific security analysis components
import semmle.python.security.dataflow.XxeQuery

// Import path graph representation for data flow tracking
import XxeFlow::PathGraph

// Identify vulnerable XML processing flows without XXE protection
from XxeFlow::PathNode source, XxeFlow::PathNode sink
where XxeFlow::flowPath(source, sink)

// Report XXE vulnerability with complete data flow path
select sink.getNode(), source, sink,
  "XML processor handles $@ without external entity expansion protection.",
  source.getNode(), "untrusted input source"