/**
 * 评估指向关系数据结构的压缩性能：分析在不同上下文深度级别下，
 * 唯一事实数量与完整关系规模的比例关系。
 * 
 * 输出指标说明：
 * - 唯一事实计数：不同(控制流节点, 目标对象, 对象类型)组合的总数
 * - 关系规模总计：包含上下文和源节点信息的完整关系数量
 * - 压缩效率：唯一事实数量占关系总规模的百分比，表示数据压缩效果
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：唯一事实计数、关系规模、上下文深度和压缩效率
from int uniqueFactsCount, int relationTotalSize, int ctxDepth, float compressionEfficiency
where
  // 确保存在指向关系并确定上下文深度
  exists(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass, PointsToContext ctxInfo |
    PointsTo::points_to(flowNode, ctxInfo, targetObject, targetClass, _) and
    ctxDepth = ctxInfo.getDepth()
  ) and
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 对象类型)组合
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass |
      // 筛选特定上下文深度的指向关系
      exists(PointsToContext ctxInfo |
        PointsTo::points_to(flowNode, ctxInfo, targetObject, targetClass, _) and
        ctxInfo.getDepth() = ctxDepth
      )
    ) and
  // 计算关系总规模：统计所有完整指向关系(包含上下文和源节点)
  relationTotalSize =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass, 
      PointsToContext ctxInfo, ControlFlowNode sourceNode |
      // 筛选特定上下文深度的完整指向关系
      PointsTo::points_to(flowNode, ctxInfo, targetObject, targetClass, sourceNode) and
      ctxInfo.getDepth() = ctxDepth
    ) and
  // 计算压缩效率：唯一事实数量占关系总规模的百分比
  compressionEfficiency = 100.0 * uniqueFactsCount / relationTotalSize
// 输出结果：上下文深度、唯一事实计数、关系规模和压缩效率
select ctxDepth, uniqueFactsCount, relationTotalSize, compressionEfficiency