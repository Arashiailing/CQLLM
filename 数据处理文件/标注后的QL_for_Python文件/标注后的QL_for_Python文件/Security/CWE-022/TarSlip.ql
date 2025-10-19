/**
 * @name Arbitrary file write during tarfile extraction
 * @description 提取恶意tar存档中的文件时，如果不验证目标文件路径是否在目标目录内，可能会导致目标目录外的文件被覆盖。
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python // 导入python库
import semmle.python.security.dataflow.TarSlipQuery // 导入TarSlip查询模块
import TarSlipFlow::PathGraph // 导入TarSlipFlow路径图模块

// 从TarSlipFlow路径图中选择源节点和汇节点
from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
// 条件：存在从源节点到汇节点的路径
where TarSlipFlow::flowPath(source, sink)
// 选择汇节点、源节点、汇节点信息，并生成警告信息
select sink.getNode(), source, sink, "This file extraction depends on a $@.", source.getNode(),
  "potentially untrusted source" // 该文件提取依赖于一个潜在的不受信任的源
