/**
 * @name Arbitrary file write during tarfile extraction
 * @description 在解压tar存档时，若未校验目标路径是否位于预期目录内，
 *              可能引发目录遍历攻击，导致覆盖目标目录外的任意文件。
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

// 声明不受信任输入源和文件提取汇点
from TarSlipFlow::PathNode untrustedInput, TarSlipFlow::PathNode extractionSink
// 验证是否存在从输入源到提取汇点的数据流路径
where TarSlipFlow::flowPath(untrustedInput, extractionSink)
// 输出结果：提取汇点、输入源、汇点详情及安全警告
select extractionSink.getNode(), untrustedInput, extractionSink, 
  "This file extraction depends on a $@.", untrustedInput.getNode(),
  "potentially untrusted source"