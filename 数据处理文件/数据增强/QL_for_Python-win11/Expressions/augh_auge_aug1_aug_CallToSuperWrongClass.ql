/**
 * @name Incorrect super() first argument
 * @description Detects calls to super() where the first parameter does not match
 *              the enclosing class name, which can lead to improper initialization
 *              in object inheritance structures.
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
from DataFlow::CallCfgNode superInvocation, string containerClassName
where
  // 确认是对super内置函数的调用
  superInvocation = API::builtin("super").getACall() and
  // 获取包含当前调用的类名
  containerClassName = superInvocation.getScope().getScope().(Class).getName() and
  // 验证第一个参数存在且与类名不匹配
  exists(DataFlow::Node initialArgument |
    initialArgument = superInvocation.getArg(0) and
    initialArgument.getALocalSource().asExpr().(Name).getId() != containerClassName
  )
// 选择问题节点并生成报告消息
select superInvocation.getNode(), "First argument to super() should be " + containerClassName + "."