/**
 * @name Python 2 中不安全的 'input' 函数使用
 * @description 检测 Python 2 中内置 'input' 函数的使用，该函数会执行任意代码。
 *              在 Python 2 中，'input()' 会将输入作为 Python 代码执行，导致代码注入漏洞。
 *              这与安全返回字符串的 'raw_input()' 函数不同。
 * @kind problem
 * @tags security
 *       correctness
 *       security/cwe/cwe-94
 *       security/cwe/cwe-95
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/use-of-input
 */

import python  // 导入 Python 代码分析库
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析库
import semmle.python.ApiGraphs  // 导入 API 图分析库

// 从数据流调用配置节点中筛选目标调用
from DataFlow::CallCfgNode unsafeInputCall
where
  // 限定分析范围：仅处理 Python 2 版本代码
  major_version() = 2
  and (
    // 识别对内置 'input' 函数的调用
    unsafeInputCall = API::builtin("input").getACall()
    // 排除安全的 'raw_input' 函数调用
    and unsafeInputCall != API::builtin("raw_input").getACall()
  )
select unsafeInputCall, "Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入攻击"