/**
 * 计算指向关系的效率。即“有趣”事实与总事实的比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义一个谓词，用于判断控制流节点是否为平凡节点
predicate trivial(ControlFlowNode f) {
  // 如果节点是参数、名称常量节点或不可变文字，则认为是平凡节点
  f.getNode() instanceof Parameter
  or
  f instanceof NameConstantNode
  or
  f.getNode() instanceof ImmutableLiteral
}

// 从以下变量中选择：有趣事实的数量、源文件中的有趣事实数量、总大小和效率
from int interesting_facts, int interesting_facts_in_source, int total_size, float efficiency
where
  // 计算有趣事实的数量，排除平凡节点
  interesting_facts =
    strictcount(ControlFlowNode f, Object value, ClassObject cls |
      f.refersTo(value, cls, _) and not trivial(f)
    ) and
  // 计算源文件中的有趣事实数量，排除平凡节点
  interesting_facts_in_source =
    strictcount(ControlFlowNode f, Object value, ClassObject cls |
      f.refersTo(value, cls, _) and
      not trivial(f) and
      exists(f.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算总的事实数量
  total_size =
    strictcount(ControlFlowNode f, PointsToContext ctx, Object value, ClassObject cls,
      ControlFlowNode orig | PointsTo::points_to(f, ctx, value, cls, orig)) and
  // 计算效率，即源文件中的有趣事实数量占总事实数量的百分比
  efficiency = 100.0 * interesting_facts_in_source / total_size
select interesting_facts, interesting_facts_in_source, total_size, efficiency
