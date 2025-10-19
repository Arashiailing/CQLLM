/**
 * @name Python 2 unsafe 'input' function detection
 * @description This rule identifies the use of Python 2's built-in 'input' function, 
 *              which evaluates user input as executable code, creating a code injection vulnerability.
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

import python  // 导入Python代码分析的基础库
import semmle.python.dataflow.new.DataFlow  // 引入数据流分析模块
import semmle.python.ApiGraphs  // 导入API图分析工具

// 检测Python 2中存在安全风险的input函数调用
from DataFlow::CallCfgNode dangerousInputUsage
where
  // 确保代码运行在Python 2环境中
  major_version() = 2 and
  // 识别对内置input函数的调用
  dangerousInputUsage = API::builtin("input").getACall()
  // 排除安全的raw_input函数调用
  and dangerousInputUsage != API::builtin("raw_input").getACall()
select dangerousInputUsage, "The unsafe built-in function 'input' is used in Python 2."  // 标记不安全的input函数调用