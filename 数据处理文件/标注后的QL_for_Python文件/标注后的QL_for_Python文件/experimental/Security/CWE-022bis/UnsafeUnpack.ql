/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 提取来自用户控制源的tar文件时，未验证目标文件路径是否在目标目录内，可能导致目标目录外的文件被覆盖。
 *             更具体地说，如果tar文件来自用户控制的位置（无论是远程位置还是命令行参数），则可能发生这种情况。
 * @kind path-problem
 * @id py/unsafe-unpacking
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python // 导入python库
import experimental.Security.UnsafeUnpackQuery // 导入实验性安全查询模块
import UnsafeUnpackFlow::PathGraph // 导入不安全解包流程的路径图模块

// 从UnsafeUnpackFlow命名空间中引入PathNode类，并定义source和sink变量
from UnsafeUnpackFlow::PathNode source, UnsafeUnpackFlow::PathNode sink
// 使用flowPath函数来查找从source到sink的路径
where UnsafeUnpackFlow::flowPath(source, sink)
// 选择sink节点、source节点和sink节点，并生成警告信息
select sink.getNode(), source, sink,
  "Unsafe extraction from a malicious tarball retrieved from a remote location." // 提示：从不安全的远程位置检索的恶意tar文件中进行不安全提取
