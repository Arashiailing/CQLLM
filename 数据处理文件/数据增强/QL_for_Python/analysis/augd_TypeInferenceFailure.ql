/**
 * @name Type inference fails for 'object'
 * @description Type inference fails for 'object' which reduces recall for many queries.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// 导入Python语言模块，提供Python代码分析的基础功能
import python

// 查找类型推断失败的object对象
from ControlFlowNode controlFlowNode, Object objectInstance
where
  // 控制流节点引用了object实例
  controlFlowNode.refersTo(objectInstance) and
  // 确保该引用不是通过其他方式（如特定上下文）进行的
  not controlFlowNode.refersTo(objectInstance, _, _)
// 选择object实例并返回类型推断失败的消息
select objectInstance, "Type inference fails for 'object'."