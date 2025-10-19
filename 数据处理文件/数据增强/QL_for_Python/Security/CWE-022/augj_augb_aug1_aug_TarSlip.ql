/**
 * @name Arbitrary file write during tarfile extraction
 * @description 检测tar文件解压过程中的路径遍历漏洞。当解压操作未验证目标路径
 *              是否在预期目录内时，攻击者可能利用恶意构造的tar包覆盖系统任意文件。
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

// 查找从不可信输入源到不安全文件提取操作的数据流路径
from TarSlipFlow::PathNode untrustedInput, TarSlipFlow::PathNode unsafeExtractionOp
where TarSlipFlow::flowPath(untrustedInput, unsafeExtractionOp)
// 输出漏洞检测结果，包括不安全提取操作、输入源和警告信息
select unsafeExtractionOp.getNode(), 
       untrustedInput, 
       unsafeExtractionOp, 
       "This file extraction depends on a $@.", 
       untrustedInput.getNode(),
       "potentially untrusted source"