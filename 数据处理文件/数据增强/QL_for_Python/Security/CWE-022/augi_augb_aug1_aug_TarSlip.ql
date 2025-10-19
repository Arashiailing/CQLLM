/**
 * @name Arbitrary file write during tarfile extraction
 * @description 检测tar存档解压过程中的路径遍历漏洞。当解压操作未验证文件路径是否
 *              限制在目标目录内时，攻击者可能利用包含"../"序列的路径覆盖任意文件。
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

// 定义不可信输入源和不安全的文件提取操作
from TarSlipFlow::PathNode taintedSource, 
     TarSlipFlow::PathNode unsafeExtraction
// 验证从不可信输入源到不安全文件提取操作的数据流路径是否存在
where TarSlipFlow::flowPath(taintedSource, unsafeExtraction)
// 输出结果：不安全的文件提取操作、不可信输入源、提取操作详情及安全警告
select unsafeExtraction.getNode(), 
       taintedSource, 
       unsafeExtraction, 
       "This file extraction depends on a $@.", 
       taintedSource.getNode(),
       "potentially untrusted source"