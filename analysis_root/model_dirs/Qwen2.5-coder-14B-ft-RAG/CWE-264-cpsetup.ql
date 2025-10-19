/**
 * @name Arbitrary file write during tarfile extraction
 * @description 提取恶意tar存档中的文件时，如果不验证目标文件路径是否在目标目录内，可能会导致目标目录外的文件被覆盖。
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph

from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
where TarSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "This file operation depends on a $@.", source.getNode(), "potentially unsafe input"