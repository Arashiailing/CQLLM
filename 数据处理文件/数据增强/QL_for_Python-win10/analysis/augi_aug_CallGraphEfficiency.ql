/**
 * 此查询用于分析Python调用图的统计特征，评估其存储效率和结构紧凑性。
 * 通过计算调用事实总数、关系元组数量、上下文深度及压缩比率来衡量调用图的质量。
 * 压缩比率反映了调用图的紧凑程度，值越高表示存储效率越好。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：totalFacts（调用事实总数）、totalRelations（关系元组总数）、maxContextDepth（最大上下文深度）和compressionRatio（压缩比率）
from int totalFacts, int totalRelations, int maxContextDepth, float compressionRatio
where
  // 计算调用图中的事实总数：统计所有唯一的调用节点与可调用对象组合
  totalFacts =
    strictcount(ControlFlowNode callSite, CallableValue targetFunction |
      exists(PointsToContext context |
        callSite = targetFunction.getACall(context) and // 获取目标函数在特定上下文中的调用点
        maxContextDepth = context.getDepth() // 记录上下文深度
      )
    ) and
  // 计算调用图关系的总大小：统计所有调用点、目标函数和上下文的三元组
  totalRelations =
    strictcount(ControlFlowNode callSite, CallableValue targetFunction, PointsToContext context |
      callSite = targetFunction.getACall(context) and // 获取目标函数在特定上下文中的调用点
      maxContextDepth = context.getDepth() // 记录上下文深度
    ) and
  // 计算压缩比率：表示调用图的存储效率，通过事实数与关系数的比率计算
  compressionRatio = 100.0 * totalFacts / totalRelations
select maxContextDepth, totalFacts, totalRelations, compressionRatio // 返回最大上下文深度、调用事实总数、关系元组总数和压缩比率