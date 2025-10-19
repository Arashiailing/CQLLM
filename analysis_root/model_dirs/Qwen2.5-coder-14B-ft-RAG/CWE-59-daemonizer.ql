/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description Extracting files from a malicious TAR file, or similar type of archive, without
 *              validating that the destination file path is within the destination directory
 *              can allow an attacker to unexpectedly gain access to resources.
 * @kind path-problem
 * @id py/daemonizer
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 */

import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph

from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
where TarSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Extraction of tarfile from $@ to a potentially untrusted source $@.", source.getNode(),
  source.getNode().toString(), sink.getNode(), sink.getNode().toString()