/**
 * @name Incorrect super() first argument
 * @description Detects instances where super() is called with a first argument
 *              that doesn't match the name of the enclosing class. This can lead
 *              to incorrect initialization in object inheritance hierarchies.
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

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// 查询变量：super()调用节点和父类名称
from DataFlow::CallCfgNode superInvocationNode, string parentClassName
where
  // 确保是对super内置函数的调用
  superInvocationNode = API::builtin("super").getACall()
  and
  // 获取包含当前调用的类名
  parentClassName = superInvocationNode.getScope().getScope().(Class).getName()
  and
  // 检查第一个参数存在且与类名不匹配
  exists(DataFlow::Node initialArgument |
    initialArgument = superInvocationNode.getArg(0) and
    initialArgument.getALocalSource().asExpr().(Name).getId() != parentClassName
  )
// 生成报告，指出正确的类名
select superInvocationNode.getNode(), "First argument to super() should be " + parentClassName + "."