/**
 * @name CWE-347: Improper Verification of Cryptographic Signature
 * @description The product does not verify, or incorrectly verifies, the cryptographic signature for data.
 * @kind path-problem
 * @problem.severity error
 * @precision medium
 * @id py/sigver
 * @tags security
 *       external/cwe/cwe-347
 */

// 导入Python基础库，用于处理Python代码分析
import python

// 导入安全数据流分析模块，用于检测不安全的签名验证流程
import semmle.python.security.dataflow.SignatureVerificationQuery

// 导入路径图模块，用于表示和可视化数据流路径
import SignatureVerificationFlow::PathGraph

// 从源节点和汇节点中选择数据流路径
from 
  SignatureVerificationFlow::PathNode source, 
  SignatureVerificationFlow::PathNode sink
  
// 确保存在从源节点到汇节点的数据流路径
where 
  SignatureVerificationFlow::flowPath(source, sink)

// 选择汇节点、源节点、路径信息以及警告消息
select 
  sink.getNode(), 
  source, 
  sink,
  "This expression uses a value from $@.", 
  source.getNode(),
  "user-supplied input"