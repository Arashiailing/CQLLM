/**
 * @name First argument to super() is not enclosing class
 * @description Calling super with something other than the enclosing class may cause incorrect object initialization.
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

// 定义查询的输入变量：super()调用节点和包围类的名称
from DataFlow::CallCfgNode superInvocation, string enclosingClass
where
  // 识别对内置函数super的调用
  superInvocation = API::builtin("super").getACall() and
  // 获取调用super()的作用域的名称（即包围类的名称）
  enclosingClass = superInvocation.getScope().getScope().(Class).getName() and
  // 检查第一个参数是否存在且不是当前类名
  exists(DataFlow::Node firstArgument |
    firstArgument = superInvocation.getArg(0) and
    // 获取第一个参数的源表达式并检查其标识符是否与包围类名不同
    firstArgument.getALocalSource().asExpr().(Name).getId() != enclosingClass
  )
// 选择调用节点并报告问题
select superInvocation.getNode(), "First argument to super() should be " + enclosingClass + "."