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

// 定义恶意输入源和易受攻击的文件提取操作
from TarSlipFlow::PathNode maliciousSource, 
     TarSlipFlow::PathNode vulnerableExtraction
// 检查是否存在从恶意输入源到易受攻击的文件提取操作的数据流路径
where TarSlipFlow::flowPath(maliciousSource, vulnerableExtraction)
// 输出结果：易受攻击的文件提取操作、恶意输入源、提取操作详情及安全警告
select vulnerableExtraction.getNode(), 
       maliciousSource, 
       vulnerableExtraction, 
       "This file extraction depends on a $@.", 
       maliciousSource.getNode(),
       "potentially untrusted source"