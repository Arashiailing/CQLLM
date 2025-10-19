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

// 识别不可信输入源和存在风险的文件提取操作
from TarSlipFlow::PathNode taintedSource, 
     TarSlipFlow::PathNode riskyFileOperation
// 验证是否存在从不可信输入源到风险文件提取操作的数据流传播
where TarSlipFlow::flowPath(taintedSource, riskyFileOperation)
// 输出分析结果：风险操作节点、污染源、数据流路径和安全警告信息
select riskyFileOperation.getNode(), 
       taintedSource, 
       riskyFileOperation, 
       "This file extraction depends on a $@.", 
       taintedSource.getNode(),
       "potentially untrusted source"