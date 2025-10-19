/**
 * @name Python 2 中使用了 'input' 函数
 * @description 检测 Python 2 代码中对内置函数 'input' 的使用。在 Python 2 中，'input' 函数会执行用户输入的代码，
 *              这可能导致任意代码执行漏洞，而 'raw_input' 函数则安全地将输入作为字符串处理。
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

import python  // 提供 Python 代码分析的基础功能
import semmle.python.dataflow.new.DataFlow  // 支持数据流分析，用于追踪代码中的值传播
import semmle.python.ApiGraphs  // 提供对 Python API 的图形化表示，便于函数调用分析

// 查找 Python 2 中不安全的 'input' 函数调用
from DataFlow::CallCfgNode vulnerableInputCall
where
  // 限制分析范围为 Python 2 版本
  major_version() = 2
  and
  // 识别对内置 'input' 函数的调用
  vulnerableInputCall = API::builtin("input").getACall()
  and
  // 排除对 'raw_input' 函数的调用，因为它是安全的
  vulnerableInputCall != API::builtin("raw_input").getACall()
select vulnerableInputCall, "The unsafe built-in function 'input' is used in Python 2."  // 报告发现的不安全调用