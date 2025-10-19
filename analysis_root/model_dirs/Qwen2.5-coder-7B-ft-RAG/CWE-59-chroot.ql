/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description This query identifies cases where a program resolves symbolic links before
 *              performing any validation, which could lead to unauthorized access to arbitrary
 *              locations on the filesystem.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/chroot
 * @tags security
 *       external/cwe/cwe-59
 */

// Import Python analysis library
import python

// Import specialized module for chroot detection queries
import semmle.python.security.dataflow.ChrootEscapeQuery

// Import class representing the flow graph for chroot detection
import ChrootEscapeFlow::PathGraph

// Define two variables representing source and sink nodes in the data flow path
from ChrootEscapeFlow::PathNode source, ChrootEscapeFlow::PathNode sink

// Condition: There must be a complete data flow path from source to sink
where ChrootEscapeFlow::flowPath(source, sink)

// Result: Sink node, source node, sink node, description message, and source context
select sink.getNode(), source, sink,
  "Potential link resolution leading to arbitrary file access through this $@.",
  source.getNode(),
  "user-supplied root directory"