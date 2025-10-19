/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 在解压用户控制的tar文件时，未校验目标路径是否位于目标目录内，可能导致目录遍历攻击。
 *             此类漏洞常见于tar文件源自不可信位置（如远程服务器或用户输入参数）的场景。
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
from UnsafeUnpackFlow::PathNode taintedSource, UnsafeUnpackFlow::PathNode vulnerableSink
// 检测是否存在从用户控制源到危险解包操作的完整数据流路径
where UnsafeUnpackFlow::flowPath(taintedSource, vulnerableSink)
// 输出漏洞位置、数据流起点和终点，并附带安全警告信息
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"