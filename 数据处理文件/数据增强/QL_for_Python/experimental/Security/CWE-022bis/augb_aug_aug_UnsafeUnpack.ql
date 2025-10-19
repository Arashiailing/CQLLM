/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 检测在解压用户提供的tar文件时是否存在路径遍历漏洞。当tar文件来自不可信来源
 *             （如外部网络或用户输入），且系统未验证解压路径是否在预期目标目录内时，
 *             攻击者可能利用此漏洞写入任意文件。
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

// 指定数据流分析的起点（不可信输入源）和终点（不安全的解压操作）
from UnsafeUnpackFlow::PathNode untrustedSourceNode, UnsafeUnpackFlow::PathNode unsafeExtractionNode
// 确认是否建立了从不可信源到不安全解压操作的数据流路径
where UnsafeUnpackFlow::flowPath(untrustedSourceNode, unsafeExtractionNode)
// 输出漏洞位置、数据流起点和终点，并附带详细的安全警告信息
select unsafeExtractionNode.getNode(), untrustedSourceNode, unsafeExtractionNode,
  "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"