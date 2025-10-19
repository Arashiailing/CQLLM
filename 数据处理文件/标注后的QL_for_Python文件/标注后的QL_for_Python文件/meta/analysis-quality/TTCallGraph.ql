/**
 * @name 使用类型跟踪而不是指向分析的新调用图边
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/type-tracking-call-graph
 * @precision very-low
 */

import python // 导入python模块，用于处理Python代码
import CallGraphQuality // 导入CallGraphQuality模块，用于评估调用图质量

// 从CallNode和Target中选择数据
from CallNode call, Target target
where
  target.isRelevant() and // 目标节点是相关的
  call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target // 调用节点通过类型跟踪解析得到的目标等于当前目标节点
select call, "$@ to $@", call, "Call", target, target.toString() // 选择调用节点、格式化字符串、调用节点标签、目标节点及其字符串表示
