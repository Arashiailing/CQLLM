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

import python  // 提供Python语言分析的基础功能
import semmle.python.dataflow.new.DataFlow  // 支持数据流分析以跟踪代码执行路径
import semmle.python.ApiGraphs  // 用于识别和分析标准库函数调用

// 查找Python 2代码中使用不安全input函数的调用点
from DataFlow::CallCfgNode unsafeInputCall
where
  // 确认目标代码运行在Python 2环境中
  major_version() = 2
  and
  // 检测对内置input函数的调用，该函数在Python 2中会执行输入的任意代码
  unsafeInputCall = API::builtin("input").getACall()
  and
  // 排除raw_input函数调用，因为该函数在Python 2中不会执行输入内容
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."  // 报告不安全的input函数使用位置