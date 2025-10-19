/**
 * 调用图统计特性分析：测量调用图的紧凑性和效率。
 * 通过计算事实数量与关系大小的比率，评估调用图的压缩效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：totalFacts（调用事实总数）、totalRelationSize（关系总大小）、
// callContextDepth（调用上下文深度）和callGraphEfficiency（调用图效率比率）
from int totalFacts, int totalRelationSize, int callContextDepth, float callGraphEfficiency
where
  // 计算调用图中的事实总数：统计所有(ControlFlowNode, CallableValue)对的数量
  exists(PointsToContext analysisContext |
    callContextDepth = analysisContext.getDepth() and // 获取并记录分析上下文的深度
    // 统计所有调用事实数量
    totalFacts =
      strictcount(ControlFlowNode callNode, CallableValue callable |
        callNode = callable.getACall(analysisContext) // 获取callable在analysisContext中的调用节点
      ) and
    // 计算调用图关系的总大小：统计所有(ControlFlowNode, CallableValue, PointsToContext)三元组的数量
    totalRelationSize =
      strictcount(ControlFlowNode callNode, CallableValue callable |
        callNode = callable.getACall(analysisContext) // 获取callable在analysisContext中的调用节点
      ) and
    // 计算调用图效率比率：将事实总数转换为相对于关系总大小的百分比
    callGraphEfficiency = 100.0 * totalFacts / totalRelationSize
  )
select callContextDepth, totalFacts, totalRelationSize, callGraphEfficiency // 返回调用上下文深度、事实总数、关系总大小和效率比率