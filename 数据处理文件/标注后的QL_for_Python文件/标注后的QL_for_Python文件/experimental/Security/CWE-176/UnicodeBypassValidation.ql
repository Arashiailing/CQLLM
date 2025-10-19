/**
 * @name Bypass Logical Validation Using Unicode Characters
 * @description A Unicode transformation is using a remote user-controlled data. The transformation is a Unicode normalization using the algorithms "NFC" or "NFKC". In all cases, the security measures implemented or the logical validation performed to escape any injection characters, to validate using regex patterns or to perform string-based checks, before the Unicode transformation are **bypassable** by special Unicode characters.
 * @kind path-problem
 * @id py/unicode-bypass-validation
 * @precision high
 * @problem.severity error
 * @tags security
 *       experimental
 *       external/cwe/cwe-176
 *       external/cwe/cwe-179
 *       external/cwe/cwe-180
 */

// 导入Python库，用于处理Python代码的查询和分析
import python

// 导入自定义的UnicodeBypassValidationQuery模块，用于检测Unicode绕过验证的问题
import UnicodeBypassValidationQuery

// 导入自定义的PathGraph类，用于路径图的构建和分析
import UnicodeBypassValidationFlow::PathGraph

// 从自定义的PathNode类中选择源节点和汇节点
from UnicodeBypassValidationFlow::PathNode source, UnicodeBypassValidationFlow::PathNode sink

// 使用自定义的flowPath函数来查找从源节点到汇节点的路径
where UnicodeBypassValidationFlow::flowPath(source, sink)

// 选择汇节点、源节点和汇节点，并生成警告信息
select sink.getNode(), source, sink,
  // 警告信息：此节点不安全地处理了远程用户控制的数据，任何在Unicode转换之前的逻辑验证都可能被特殊Unicode字符绕过
  "This $@ processes unsafely $@ and any logical validation in-between could be bypassed using special Unicode characters.",
  sink.getNode(), "Unicode transformation (Unicode normalization)", source.getNode(),
  "remote user-controlled data"
