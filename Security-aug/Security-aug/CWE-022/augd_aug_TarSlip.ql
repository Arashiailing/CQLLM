/**
 * @name Arbitrary file write during tarfile extraction
 * @description 解压tar归档文件时，若未校验目标路径是否在目标目录范围内，
 *              可能导致目录遍历攻击，允许覆盖目标目录外的任意文件。
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

// 定义恶意输入源和文件提取目标点
from TarSlipFlow::PathNode maliciousInput, TarSlipFlow::PathNode extractionSink
// 验证存在从恶意输入到提取点的数据流路径
where TarSlipFlow::flowPath(maliciousInput, extractionSink)
// 输出结果，包含提取点、输入源、路径信息和警告消息
select extractionSink.getNode(), maliciousInput, extractionSink, 
  "此文件提取依赖于 $@.", maliciousInput.getNode(),
  "潜在不可信的输入源"