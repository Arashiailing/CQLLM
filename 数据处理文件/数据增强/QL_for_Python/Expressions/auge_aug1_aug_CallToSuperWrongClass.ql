/**
 * @name Misleading super() first parameter
 * @description Identifies instances where super() is invoked with an initial argument
 *              that differs from the containing class name, potentially causing
 *              incorrect initialization behavior in inheritance hierarchies.
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

// 定义查询的输入变量：super()调用节点和封闭类的名称
from DataFlow::CallCfgNode superCall, string enclosingClassName
where
  // 验证节点确实是对super内置函数的调用
  superCall = API::builtin("super").getACall() and
  // 获取当前类作用域的名称作为封闭类名
  enclosingClassName = superCall.getScope().getScope().(Class).getName() and
  // 检查是否存在第一个参数且与封闭类名不匹配
  exists(DataFlow::Node firstArg |
    firstArg = superCall.getArg(0) and
    // 比较第一个参数的标识符与封闭类名
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
// 选择问题节点并生成报告消息
select superCall.getNode(), "First argument to super() should be " + enclosingClassName + "."