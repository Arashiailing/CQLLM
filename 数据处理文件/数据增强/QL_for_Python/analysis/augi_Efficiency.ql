/**
 * 分析指向关系的效率指标。计算“非平凡事实”在总事实中的占比，
 * 并区分源文件内事实与全局事实的分布情况。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义谓词：判断控制流节点是否为平凡节点（参数/常量/不可变字面量）
predicate trivial(ControlFlowNode node) {
  // 以下任一条件成立即视为平凡节点
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算四项关键指标：全局非平凡事实数、源文件内非平凡事实数、总事实数、效率百分比
from int global_nontrivial_facts, int source_nontrivial_facts, int total_facts, float efficiency_metric
where
  // 计算全局非平凡事实数（排除平凡节点）
  global_nontrivial_facts =
    strictcount(ControlFlowNode node, Object target, ClassObject classType |
      node.refersTo(target, classType, _) and not trivial(node)
    ) and
  // 计算源文件内非平凡事实数（需满足文件路径存在条件）
  source_nontrivial_facts =
    strictcount(ControlFlowNode node, Object target, ClassObject classType |
      node.refersTo(target, classType, _) and
      not trivial(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算总事实数（包含所有指向关系）
  total_facts =
    strictcount(ControlFlowNode node, PointsToContext context, Object target, 
                ClassObject classType, ControlFlowNode origin |
      PointsTo::points_to(node, context, target, classType, origin)
    ) and
  // 计算效率指标：源文件内非平凡事实占总事实的百分比
  efficiency_metric = 100.0 * source_nontrivial_facts / total_facts
select global_nontrivial_facts, source_nontrivial_facts, total_facts, efficiency_metric