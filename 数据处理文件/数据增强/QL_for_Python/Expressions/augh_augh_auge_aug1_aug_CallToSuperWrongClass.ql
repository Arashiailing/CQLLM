/**
 * @name Incorrect super() first argument
 * @description Identifies super() invocations where the first parameter
 *              does not correspond to the enclosing class name. This
 *              mismatch can result in improper initialization within
 *              object inheritance hierarchies.
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
from DataFlow::CallCfgNode superCallNode, string enclosingClassName
where
  // 确认是对super内置函数的调用
  superCallNode = API::builtin("super").getACall()
  and
  // 获取包含当前调用的类名
  enclosingClassName = superCallNode.getScope().getScope().(Class).getName()
  and
  // 验证第一个参数存在且与类名不匹配
  exists(DataFlow::Node firstArgument |
    firstArgument = superCallNode.getArg(0)
    and
    firstArgument.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
// 选择问题节点并生成报告消息
select superCallNode.getNode(), "First argument to super() should be " + enclosingClassName + "."