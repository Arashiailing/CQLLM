/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 检测从用户控制的源提取tar文件时，未验证目标路径是否在目标目录内的漏洞。
 *             这种漏洞可能导致目录遍历攻击，特别是当tar文件来自不受信任的位置时。
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

// 查找不安全的解包操作：从不信任的源到危险解包操作的数据流
from UnsafeUnpackFlow::PathNode untrustedInput, UnsafeUnpackFlow::PathNode unsafeExtraction
where UnsafeUnpackFlow::flowPath(untrustedInput, unsafeExtraction)
// 输出漏洞位置、数据流起点和终点，并生成安全警告
select unsafeExtraction.getNode(), untrustedInput, unsafeExtraction,
  "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"