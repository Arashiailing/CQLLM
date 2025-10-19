/**
 * @name Misleading super() first parameter
 * @description Detects super() calls where the first argument does not match
 *              the containing class name, which can lead to incorrect initialization
 *              in class inheritance hierarchies.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 *       external/cwe/cwe-687
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/super-not-enclosing-class
 */

import python  // 导入Python库，用于分析Python代码
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析模块
import semmle.python.ApiGraphs  // 导入API图模块

// 定义查询的输入变量：super()调用节点和包含类的名称
from DataFlow::CallCfgNode superInvocation, string containerClassName
where
  // 确保节点是对super内置函数的调用
  superInvocation = API::builtin("super").getACall() and
  // 获取当前类作用域的名称作为包含类名
  containerClassName = superInvocation.getScope().getScope().(Class).getName() and
  // 检查第一个参数存在且与包含类名不匹配
  exists(DataFlow::Node initialParameter |
    initialParameter = superInvocation.getArg(0) and
    // 比较第一个参数的标识符与包含类名
    initialParameter.getALocalSource().asExpr().(Name).getId() != containerClassName
  )
// 选择问题节点并生成报告消息
select superInvocation.getNode(), "First argument to super() should be " + containerClassName + "."