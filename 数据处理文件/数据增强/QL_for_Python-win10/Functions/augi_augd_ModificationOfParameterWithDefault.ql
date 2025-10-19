/**
 * @name Modification of parameter with default
 * @description 修改具有默认值的参数可能导致意外结果，因为默认值在函数定义时创建一次，后续调用会共享同一对象。
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
  // 定义具有默认值的参数节点（默认值）
  ModificationOfParameterWithDefault::Flow::PathNode defaultParamNode,
  // 定义修改该参数的变异点节点
  ModificationOfParameterWithDefault::Flow::PathNode mutationPointNode
where 
  // 检测从默认参数到修改操作的完整数据流路径
  ModificationOfParameterWithDefault::Flow::flowPath(defaultParamNode, mutationPointNode)
select 
  mutationPointNode.getNode(), 
  defaultParamNode, 
  mutationPointNode, 
  "This expression mutates a $@.", 
  defaultParamNode.getNode(),
  "default value"