/**
 * @name Python 2 中不安全的 'input' 函数使用
 * @description 识别 Python 2 代码中对内置 'input' 函数的调用。
 *              Python 2 中的 'input()' 函数会将用户输入作为 Python 代码执行，
 *              这可能导致任意代码执行漏洞。相比之下，'raw_input()' 函数会安全地
 *              将输入作为字符串返回，不会执行代码。
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

import python  // 导入 Python 代码分析基础库
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析功能
import semmle.python.ApiGraphs  // 导入 API 图分析功能

// 定义变量：可能存在漏洞的 input 函数调用节点
from DataFlow::CallCfgNode vulnerableInputCall
where
  // 条件1：确保代码运行在 Python 2 环境中
  major_version() = 2
  and (
    // 条件2：识别对内置 'input' 函数的调用
    vulnerableInputCall = API::builtin("input").getACall()
    // 条件3：排除安全的 'raw_input' 函数调用
    and vulnerableInputCall != API::builtin("raw_input").getACall()
  )
select vulnerableInputCall, "Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入攻击"