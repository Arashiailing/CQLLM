/**
 * @name Python 2 不安全的 input 函数检测
 * @description 检测 Python 2 中内置 'input' 函数的使用，该函数会执行输入的任意代码，
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

import python  // Python 代码静态分析核心库
import semmle.python.dataflow.new.DataFlow  // 数据流分析工具
import semmle.python.ApiGraphs  // API 调用图分析工具

// 检测 Python 2 环境中的不安全 input 函数调用
from DataFlow::CallCfgNode riskyInputCall
where
  // 检查 Python 版本
  major_version() = 2
  // 检查是否为 input 函数调用
  and riskyInputCall = API::builtin("input").getACall()
  // 排除安全的 raw_input 函数
  and riskyInputCall != API::builtin("raw_input").getACall()
select riskyInputCall, "Python 2 中使用了不安全的内置函数 'input'。"  // 标记并报告不安全的 input 函数调用