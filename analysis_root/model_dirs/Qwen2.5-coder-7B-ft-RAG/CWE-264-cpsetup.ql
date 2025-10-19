/**
 * @name TarSlipQuery
 * @description Extracting files from a malicious tar archive without verifying
 *              that the destination file path is within the target directory
 *              can lead to arbitrary file writes outside the intended directory.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/tarslip
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import experimental.semmle.python.security.TarSlipQuery
import TarSlipFlow::PathGraph

from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
where TarSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Destination path of this file extraction depends on a $@.", source.getNode(),
  "user-controlled value"