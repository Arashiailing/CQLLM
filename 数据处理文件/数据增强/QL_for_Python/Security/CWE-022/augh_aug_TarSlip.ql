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

// 定义不受信任的数据源和文件提取操作点
from TarSlipFlow::PathNode taintedSource, TarSlipFlow::PathNode extractSink
// 验证是否存在从污染源到提取操作点的数据流传播路径
where TarSlipFlow::flowPath(taintedSource, extractSink)
// 输出检测结果：提取操作点、污染源、传播路径及安全警告
select extractSink.getNode(), taintedSource, extractSink, 
  "This file extraction depends on a $@.", taintedSource.getNode(),
  "potentially untrusted source"