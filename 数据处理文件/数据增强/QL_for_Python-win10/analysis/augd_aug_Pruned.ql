import python  // 导入Python语言分析模块，提供语法树节点和基础语义模型
import semmle.python.pointsto.PointsTo  // 导入指针分析模块，用于追踪变量引用和对象访问关系

// 统计Python代码中不可达基本块内的控制流节点总数
// 注：此查询统计的是不可达基本块中的控制流节点数量，而非不可达基本块的数量
// 不可达基本块是指在控制流图中无法从入口点到达的代码区域
from int deadBlockNodeCount  // 声明整型变量用于存储不可达基本块中的节点总数
where 
  // 聚合计算所有控制流节点中，其所属基本块被标记为不可达的数量
  deadBlockNodeCount = count(ControlFlowNode flowNode | 
    // 判断条件：控制流节点所在的基本块不被PointsTo分析认为是可达的
    not PointsToInternal::reachableBlock(flowNode.getBasicBlock(), _)
  )
select deadBlockNodeCount  // 返回不可达基本块中的控制流节点总数