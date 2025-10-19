/**
 * @name 'input' function used in Python 2
 * @description The built-in function 'input' is used which, in Python 2, can allow arbitrary code to be run.
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

import python  // 导入Python分析模块，提供Python代码分析基础功能
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析模块，用于跟踪代码执行路径
import semmle.python.ApiGraphs  // 导入API图模块，用于识别内置函数调用

// 定义查询变量：查找所有调用配置节点
from DataFlow::CallCfgNode unsafeInputCall
where
  // 限制分析范围：仅针对Python 2版本
  major_version() = 2 and
  // 识别对内置'input'函数的调用
  unsafeInputCall = API::builtin("input").getACall() and
  // 排除对'raw_input'函数的调用，因为它是安全的
  unsafeInputCall != API::builtin("raw_input").getACall()
// 输出结果：不安全的'input'函数调用位置及警告信息
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."