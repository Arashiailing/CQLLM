/**
 * @name Arbitrary file write during tarfile extraction
 * @description 当提取tar存档中的文件时，若未验证目标文件路径是否在目标目录范围内，
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

// 识别潜在受污染的数据源和文件提取操作点
from TarSlipFlow::PathNode taintedSource, TarSlipFlow::PathNode extractionSink
// 验证从受污染源到提取操作点的数据流传播路径
where TarSlipFlow::flowPath(taintedSource, extractionSink)
// 输出分析结果：提取点、污染源、路径节点及安全警告
select extractionSink.getNode(), taintedSource, extractionSink, 
  "This file extraction depends on a $@.", taintedSource.getNode(),
  "tainted source"