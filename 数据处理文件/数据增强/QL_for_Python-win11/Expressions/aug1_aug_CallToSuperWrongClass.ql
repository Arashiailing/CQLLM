/**
 * @name Incorrect first argument in super() call
 * @description Detects super() calls where the first argument is not the enclosing class,
 *              which can lead to improper object initialization.
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

// 定义查询的输入变量：super()调用节点和容器类的名称
from DataFlow::CallCfgNode superInvocation, string containerClassName
where
  // 验证节点确实是对super内置函数的调用
  superInvocation = API::builtin("super").getACall() and
  // 获取当前类作用域的名称作为容器类名
  containerClassName = superInvocation.getScope().getScope().(Class).getName() and
  // 检查是否存在第一个参数且与容器类名不匹配
  exists(DataFlow::Node initialArgument |
    initialArgument = superInvocation.getArg(0) and
    // 比较第一个参数的标识符与容器类名
    initialArgument.getALocalSource().asExpr().(Name).getId() != containerClassName
  )
// 选择问题节点并生成报告消息
select superInvocation.getNode(), "First argument to super() should be " + containerClassName + "."