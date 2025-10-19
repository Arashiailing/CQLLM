/**
 * @name 恶意tar文件提取时的任意文件写入漏洞
 * @description 当从用户控制源提取tar文件时，若未验证目标路径是否在预期目录内，
 *             攻击者可能覆盖目标目录外的文件。此漏洞常见于从远程位置或命令行参数
 *             获取的tar文件处理场景。
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

// 定义恶意输入源和不安全提取操作节点
from UnsafeUnpackFlow::PathNode maliciousInput, UnsafeUnpackFlow::PathNode vulnerableExtraction
// 检测从恶意输入源到不安全提取操作的数据流路径
where UnsafeUnpackFlow::flowPath(maliciousInput, vulnerableExtraction)
// 输出漏洞位置、数据流起点和终点，附带安全警告
select vulnerableExtraction.getNode(), maliciousInput, vulnerableExtraction,
  "检测到从远程位置获取的恶意tar文件的不安全提取操作，可能导致目录遍历攻击"