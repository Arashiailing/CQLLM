/**
 * @name Arbitrary file write during tarfile extraction
 * @description 解压tar存档时，若未验证目标路径是否位于预期目录内，
 *              可能引发目录遍历攻击，导致目标目录外任意文件被覆盖。
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

// 定义未受信任的源节点和文件提取汇点节点
from TarSlipFlow::PathNode untrustedSource, TarSlipFlow::PathNode extractionSink
// 检查是否存在从未受信任源到文件提取汇点的数据流传播路径
where TarSlipFlow::flowPath(untrustedSource, extractionSink)
// 输出结果：提取操作位置、未受信任源节点、完整路径及安全警告
select extractionSink.getNode(), untrustedSource, extractionSink, 
  "This file extraction depends on a $@.", untrustedSource.getNode(),
  "potentially untrusted source"