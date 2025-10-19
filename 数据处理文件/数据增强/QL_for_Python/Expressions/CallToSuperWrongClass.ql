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

// 定义一个数据流节点，表示对super()的调用
from DataFlow::CallCfgNode call_to_super, string name
where
  // 找到对内置函数super的调用
  call_to_super = API::builtin("super").getACall() and
  // 获取调用super()的作用域的名称
  name = call_to_super.getScope().getScope().(Class).getName() and
  // 检查第一个参数是否不是当前类名
  exists(DataFlow::Node arg |
    arg = call_to_super.getArg(0) and
    arg.getALocalSource().asExpr().(Name).getId() != name
  )
// 选择调用节点并报告问题
select call_to_super.getNode(), "First argument to super() should be " + name + "."
