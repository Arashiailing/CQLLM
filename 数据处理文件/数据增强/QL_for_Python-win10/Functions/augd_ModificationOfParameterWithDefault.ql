/**
 * @name Modification of parameter with default
 * @description 修改具有默认值的参数可能导致意外结果。
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
  ModificationOfParameterWithDefault::Flow::PathNode paramNode,  // 参数节点（默认值）
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode // 修改节点（变异点）
where 
  // 检测从默认参数到修改操作的完整数据流路径
  ModificationOfParameterWithDefault::Flow::flowPath(paramNode, mutationNode)
select 
  mutationNode.getNode(), 
  paramNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  paramNode.getNode(),
  "default value"