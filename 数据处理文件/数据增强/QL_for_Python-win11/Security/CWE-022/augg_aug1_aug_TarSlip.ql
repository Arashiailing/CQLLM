/**
 * @name Tar extraction with arbitrary file write
 * @description 解压tar文件时，如果未验证目标路径是否在预期目录内，
 *              攻击者可能利用路径遍历覆盖任意文件。
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

// 定义不可信输入源和文件提取目标点
from TarSlipFlow::PathNode untrustedSource, TarSlipFlow::PathNode extractionTarget
// 检查是否存在从输入源到提取目标的数据流路径
where TarSlipFlow::flowPath(untrustedSource, extractionTarget)
// 输出结果：提取目标点、输入源、目标点详情及安全警告
select extractionTarget.getNode(), untrustedSource, extractionTarget, 
  "This file extraction depends on a $@.", untrustedSource.getNode(),
  "potentially untrusted source"