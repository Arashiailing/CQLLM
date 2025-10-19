/**
 * @name 调用图边际事实增长分析
 * @description 评估不同上下文深度下调用关系的规模分布及其效率比率，帮助理解调用图的增长模式。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：distinctCallCount（唯一调用数）、totalCallCount（全上下文调用数）、
// callContextDepth（上下文深度）和callEfficiencyRatio（调用效率）
from int distinctCallCount, int totalCallCount, int callContextDepth, float callEfficiencyRatio
where
  // 计算在指定上下文深度下的唯一调用数（不包含在更浅上下文中的调用）
  distinctCallCount =
    strictcount(ControlFlowNode callNode, CallableValue callable |
      exists(PointsToContext context |
        callNode = callable.getACall(context) and // 获取函数在特定上下文中的调用节点
        callContextDepth = context.getDepth() and // 获取当前上下文深度
        // 确保没有更浅上下文中存在相同调用
        not exists(PointsToContext shallowerContext |
          callNode = callable.getACall(shallowerContext) and
          shallowerContext.getDepth() < callContextDepth
        )
      )
    ) and

  // 计算在指定上下文深度下的全上下文调用总数
  totalCallCount =
    strictcount(ControlFlowNode callNode, CallableValue callable, PointsToContext context |
      callNode = callable.getACall(context) and // 获取函数在任意上下文中的调用节点
      callContextDepth = context.getDepth() // 获取上下文深度
    ) and

  // 计算调用效率比率：唯一调用数占总调用数的百分比
  callEfficiencyRatio = 100.0 * distinctCallCount / totalCallCount
select callContextDepth, distinctCallCount, totalCallCount, callEfficiencyRatio // 输出结果：上下文深度、唯一调用数、全上下文调用数和调用效率