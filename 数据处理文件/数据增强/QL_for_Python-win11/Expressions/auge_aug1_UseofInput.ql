/**
 * @name Detection of unsafe 'input' function in Python 2
 * @description Identifies usage of the built-in 'input' function which, in Python 2, 
 *              can execute arbitrary code provided as input, posing a security risk.
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

import python  // 导入Python代码分析基础库，提供Python语言分析能力
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析模块，用于追踪代码执行路径
import semmle.python.ApiGraphs  // 导入API图分析工具，用于识别标准库函数调用

// 检测Python 2环境中存在安全风险的input函数调用实例
from DataFlow::CallCfgNode riskyInputInvocation
where
  // 确保分析目标为Python 2版本，因为input函数的安全问题仅存在于该版本
  major_version() = 2 and
  // 识别对内置input函数的调用，该函数在Python 2中会执行输入的代码
  riskyInputInvocation = API::builtin("input").getACall() and
  // 明确排除raw_input函数调用，因为该函数在Python 2中是安全的，不会执行输入内容
  riskyInputInvocation != API::builtin("raw_input").getACall()
select riskyInputInvocation, "The unsafe built-in function 'input' is used in Python 2."  // 输出检测结果，标记不安全的input函数使用位置