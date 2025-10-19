/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 在解压用户提供的tar文件时，若未验证目标路径是否在目标目录内，可能导致目录遍历攻击。
 *             此漏洞常见于tar文件源自不可信位置（如远程服务器或用户输入参数）的场景。
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

// 指定数据流分析的起始点（用户控制源）和结束点（不安全的解压操作）
from UnsafeUnpackFlow::PathNode startNode, UnsafeUnpackFlow::PathNode endNode
// 检查是否存在从用户控制源到不安全解压操作的数据流路径
where UnsafeUnpackFlow::flowPath(startNode, endNode)
// 输出漏洞节点、数据流起点和终点，并附带安全警告信息
select endNode.getNode(), startNode, endNode,
  "解压操作存在风险：来自不可信远程源的恶意tar文件可能被利用进行目录遍历攻击"