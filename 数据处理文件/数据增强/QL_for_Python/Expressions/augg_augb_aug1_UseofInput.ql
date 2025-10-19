/**
 * @name Python 2 不安全的 input 函数检测
 * @description 在 Python 2 中，内置的 'input' 函数会执行用户输入的任意代码，
 *              这可能导致代码注入攻击。本查询用于检测此类不安全的使用情况。
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

import python  // Python 代码静态分析核心库
import semmle.python.dataflow.new.DataFlow  // 数据流分析工具
import semmle.python.ApiGraphs  // API 调用图分析工具

// 查找 Python 2 代码中使用不安全 input 函数的调用点
from DataFlow::CallCfgNode unsafeInputUsage
where
  // 确保是对 input 函数的调用，而不是安全的 raw_input 函数
  unsafeInputUsage = API::builtin("input").getACall()
  and unsafeInputUsage != API::builtin("raw_input").getACall()
  // 限定为 Python 2 环境
  and major_version() = 2
select unsafeInputUsage, "Python 2 中使用了不安全的内置函数 'input'。"  // 报告不安全的 input 函数调用