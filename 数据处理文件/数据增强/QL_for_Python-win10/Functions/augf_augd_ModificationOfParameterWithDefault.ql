/**
 * @name Modification of parameter with default
 * @description 修改具有默认值的参数可能导致意外结果，因为默认值在函数定义时初始化并共享。
 * @kind path-problem
 * @tags reliability 可靠性
 *       maintainability 可维护性
 * @problem.severity error 错误严重级别
 * @sub-severity low 低子严重级别
 * @precision high 高精确度
 * @id py/modification-of-default-value
 */

import python
import semmle.python.functions.ModificationOfParameterWithDefault
import ModificationOfParameterWithDefault::Flow::PathGraph

from
  ModificationOfParameterWithDefault::Flow::PathNode defaultValueNode,  // 默认值参数节点
  ModificationOfParameterWithDefault::Flow::PathNode mutationPointNode // 参数修改操作节点
where 
  // 检测从默认值参数到修改操作的完整数据流路径
  ModificationOfParameterWithDefault::Flow::flowPath(defaultValueNode, mutationPointNode)
select 
  mutationPointNode.getNode(), 
  defaultValueNode, 
  mutationPointNode, 
  "This expression mutates a $@.", 
  defaultValueNode.getNode(),
  "default value"