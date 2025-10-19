/**
 * @name Path traversal and equivalence errors
 * @description Detects conditions where pathname traversal may occur, leading to unauthorized access.
 * @kind problem
 * @tags deprecated
 * @problem.severity warning
 * @security-severity 6.5
 * @precision medium
 * @id py/pathutils
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.ExportFlow::PathGraph
import semmle.python.Concepts

from ExportFlow::PathNode source, ExportFlow::PathNode sink
where ExportFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Exporting a value without validating its origin may enable unsafe path traversal."