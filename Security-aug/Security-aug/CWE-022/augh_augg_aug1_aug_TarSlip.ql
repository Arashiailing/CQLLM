/**
 * @name Tar extraction with arbitrary file write
 * @description 检测tar文件解压过程中的路径遍历漏洞。当解压操作未验证目标路径是否位于预期目录内时，
 *              攻击者可能通过构造恶意路径覆盖系统任意文件。
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

// 定义漏洞检测核心变量
from TarSlipFlow::PathNode maliciousInputSource, TarSlipFlow::PathNode vulnerableExtractionPoint
// 验证存在从恶意输入源到易受攻击解压点的数据流路径
where TarSlipFlow::flowPath(maliciousInputSource, vulnerableExtractionPoint)
// 输出漏洞结果：解压点位置、输入源位置、解压点详情及安全警告
select vulnerableExtractionPoint.getNode(), maliciousInputSource, vulnerableExtractionPoint, 
  "This file extraction depends on a $@.", maliciousInputSource.getNode(),
  "potentially untrusted source"