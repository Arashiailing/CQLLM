/**
 * @name Arbitrary file write during tarfile extraction
 * @description 在解压tar存档时，若未验证目标文件路径是否在目标目录内，可能导致目录遍历攻击（TarSlip），使攻击者能够覆盖目标目录外的任意文件。
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

// 检测从不受信任源到文件提取操作的数据流路径
from TarSlipFlow::PathNode maliciousSource, TarSlipFlow::PathNode vulnerableExtraction
where TarSlipFlow::flowPath(maliciousSource, vulnerableExtraction)
// 报告存在目录遍历风险的文件提取操作
select vulnerableExtraction.getNode(), maliciousSource, vulnerableExtraction, 
  "This file extraction depends on a $@.", maliciousSource.getNode(),
  "potentially untrusted source" // 该文件提取依赖于一个潜在的不受信任的源