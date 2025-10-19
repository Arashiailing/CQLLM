/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 识别从用户控制的源解压tar文件时，未校验目标路径是否在预期目录内的安全缺陷。
 *             此类缺陷可引发目录遍历攻击，尤其在处理来自不可信源的tar文件时风险显著。
 * @kind path-problem
 * @id py/unsafe-unpacking
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import experimental.Security.UnsafeUnpackQuery
import UnsafeUnpackFlow::PathGraph

// 识别危险数据流：从不可信输入源到不安全解压操作
from UnsafeUnpackFlow::PathNode maliciousSource, UnsafeUnpackFlow::PathNode vulnerableExtraction
where UnsafeUnpackFlow::flowPath(maliciousSource, vulnerableExtraction)
// 输出漏洞位置、数据流起点和终点，并生成安全告警
select vulnerableExtraction.getNode(), maliciousSource, vulnerableExtraction,
  "危险解压操作：从不可信远程源获取的恶意tar文件可能导致目录遍历攻击"