/**
 * @name Python 2 中不安全的 'input' 函数检测
 * @description 识别在 Python 2 中使用内置 'input' 函数的情况，该函数会执行输入的任意代码，
 *              存在严重的安全风险。
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

import python  // 提供Python代码分析的基础功能
import semmle.python.dataflow.new.DataFlow  // 支持数据流分析，追踪代码执行路径
import semmle.python.ApiGraphs  // 用于识别和分析标准库函数调用

// 查找Python 2中使用不安全input函数的调用点
from DataFlow::CallCfgNode unsafeInputCall
where
  // 限制分析范围：仅针对Python 2版本
  major_version() = 2 and
  // 识别对内置input函数的调用（排除安全的raw_input函数）
  unsafeInputCall = API::builtin("input").getACall() and
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "在Python 2中使用了不安全的内置函数'input'。"  // 报告检测结果，指明不安全的input函数使用位置