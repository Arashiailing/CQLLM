/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 检测从用户控制的源提取tar文件时，未验证目标路径是否在目标目录内的情况。
 *             此漏洞可能被攻击者利用进行目录遍历攻击，特别是当tar文件源自不可信来源时。
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

// 查询目标：识别从不可信输入源到危险解包函数的数据流路径
from 
  // 数据流起点：表示用户控制的或不可信的输入源
  UnsafeUnpackFlow::PathNode maliciousInputSource,
  // 数据流终点：表示存在漏洞的解包操作点
  UnsafeUnpackFlow::PathNode vulnerableExtraction
where 
  // 验证从输入源到解包操作存在完整的数据流路径，表明存在潜在安全风险
  UnsafeUnpackFlow::flowPath(maliciousInputSource, vulnerableExtraction)
// 输出漏洞信息，包括漏洞位置、数据流路径和风险描述
select vulnerableExtraction.getNode(), maliciousInputSource, vulnerableExtraction,
  "不安全的解包操作：从不可信远程源获取的恶意tar文件可能导致目录遍历攻击"