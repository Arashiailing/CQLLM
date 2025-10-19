/**
 * @name Python 2 中不安全的 'input' 函数使用
 * @description 在 Python 2 中，内置的 'input()' 函数会将用户输入作为 Python 代码执行，
 *              这可能导致严重的代码注入漏洞。相比之下，'raw_input()' 函数会安全地返回字符串。
 *              本查询旨在识别并报告所有使用不安全 'input' 函数的代码位置。
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

// 定义变量以捕获不安全的 input 函数调用
from DataFlow::CallCfgNode problematicInputCall
where
  // 限定分析范围：仅处理 Python 2 版本代码
  major_version() = 2
  and (
    // 识别对内置 'input' 函数的调用
    problematicInputCall = API::builtin("input").getACall()
    // 排除安全的 'raw_input' 函数调用
    and problematicInputCall != API::builtin("raw_input").getACall()
  )
select problematicInputCall, "检测到 Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入攻击"