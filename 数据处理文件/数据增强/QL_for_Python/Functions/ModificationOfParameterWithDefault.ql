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

import python // 导入Python库
import semmle.python.functions.ModificationOfParameterWithDefault // 导入特定功能模块
import ModificationOfParameterWithDefault::Flow::PathGraph // 导入路径图类

from
  ModificationOfParameterWithDefault::Flow::PathNode source, // 定义源节点
  ModificationOfParameterWithDefault::Flow::PathNode sink // 定义目标节点
where ModificationOfParameterWithDefault::Flow::flowPath(source, sink) // 条件：存在从源到目标的路径
select sink.getNode(), source, sink, "This expression mutates a $@.", source.getNode(),
  "default value" // 选择目标节点、源节点和相关描述信息，表示该表达式修改了某个默认值
