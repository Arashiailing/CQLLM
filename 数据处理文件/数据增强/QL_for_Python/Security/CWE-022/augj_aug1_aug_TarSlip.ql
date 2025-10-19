/**
 * @name Arbitrary file write during tarfile extraction
 * @description 在解压tar存档文件时，若未校验目标路径是否位于预期目录内，
 *              可能导致目录遍历攻击，造成目标目录外任意文件被覆盖。
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph

// 定义不受信任的输入源和文件提取目标点
from TarSlipFlow::PathNode untrustedSource, TarSlipFlow::PathNode extractionTarget
// 检查是否存在从输入源到提取目标的数据流路径
where TarSlipFlow::flowPath(untrustedSource, extractionTarget)
// 输出结果：提取目标位置、输入源、目标详情及安全警告
select extractionTarget.getNode(), untrustedSource, extractionTarget, 
  "This file extraction depends on a $@.", untrustedSource.getNode(),
  "potentially untrusted source"