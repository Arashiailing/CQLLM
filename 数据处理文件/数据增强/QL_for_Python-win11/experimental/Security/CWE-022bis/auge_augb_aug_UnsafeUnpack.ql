/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 检测从用户控制的源提取tar文件时，未验证目标路径是否在目标目录内的情况。
 *             这种漏洞可能导致目录遍历攻击，特别是当tar文件来自不受信任的来源时。
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

// 查询目标：识别从不信任的源到危险解包操作的数据流路径
from 
  // 定义数据流起点：代表用户控制的输入源
  UnsafeUnpackFlow::PathNode untrustedSource,
  // 定义数据流终点：代表可能存在漏洞的解包操作
  UnsafeUnpackFlow::PathNode dangerousSink
where 
  // 确认存在从源到汇的数据流路径，表明潜在的安全风险
  UnsafeUnpackFlow::flowPath(untrustedSource, dangerousSink)
// 输出漏洞详情，包括位置、数据流路径和描述信息
select dangerousSink.getNode(), untrustedSource, dangerousSink,
  "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"