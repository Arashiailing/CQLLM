/**
 * @name Arbitrary file write during tarfile extraction
 * @description 处理tar归档解压时，若未对目标路径进行安全边界检查，
 *              攻击者可能通过路径遍历技术覆盖目标目录外的任意文件。
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

// 检测不可信输入源到文件解压点的数据流传播路径
from TarSlipFlow::PathNode taintedSource, TarSlipFlow::PathNode fileExtractionPoint
where TarSlipFlow::flowPath(taintedSource, fileExtractionPoint)
// 报告漏洞信息，包括受影响的解压操作、输入源、数据流路径及安全警告
select fileExtractionPoint.getNode(), taintedSource, fileExtractionPoint, 
  "此文件提取操作依赖于 $@.", taintedSource.getNode(),
  "未经验证的恶意输入源"