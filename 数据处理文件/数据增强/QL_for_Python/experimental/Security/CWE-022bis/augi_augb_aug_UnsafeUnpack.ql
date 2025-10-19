/**
 * @name 用户控制源导致的tarball提取过程中的任意文件写入漏洞
 * @description 在解压用户控制的tar文件时，如果未验证目标路径是否在目标目录内，攻击者可能利用目录遍历攻击写入任意文件。
 *             此漏洞通常出现在tar文件来源不可信的场景，例如从远程服务器获取或由用户输入参数指定。
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

// 定义数据流分析的起点（用户控制源）和终点（危险解包操作）
from UnsafeUnpackFlow::PathNode untrustedSourceNode, UnsafeUnpackFlow::PathNode dangerousSinkNode
// 验证是否存在从用户控制源到危险解包操作的数据流路径
where UnsafeUnpackFlow::flowPath(untrustedSourceNode, dangerousSinkNode)
// 输出漏洞位置、数据流起点和终点，并生成安全警告
select dangerousSinkNode.getNode(), untrustedSourceNode, dangerousSinkNode,
  "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"