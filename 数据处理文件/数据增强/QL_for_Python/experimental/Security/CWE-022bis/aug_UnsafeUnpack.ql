/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 当提取用户控制的tar文件时，未验证目标路径是否在目标目录内，可能导致目录遍历攻击。
 *             这种漏洞发生在tar文件源自不受信任的位置（如远程服务器或用户输入参数）。
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

// 定义危险解包操作的起始点和结束点
from UnsafeUnpackFlow::PathNode originNode, UnsafeUnpackFlow::PathNode targetNode
// 验证是否存在从用户控制源到危险解包操作的数据流路径
where UnsafeUnpackFlow::flowPath(originNode, targetNode)
// 输出漏洞位置、数据流起点和终点，并生成安全警告
select targetNode.getNode(), originNode, targetNode,
  "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"