import python  // 导入Python语言分析库，用于处理Python代码的语法结构和语义模型
import semmle.python.pointsto.PointsTo  // 引入指向分析功能，用于追踪变量和对象的引用关系

// 统计Python代码中无法被执行到的基本块数量
// 这些基本块在控制流图中与程序入口点没有路径连接
from int deadBlockTotal  // 定义变量来保存不可达基本块的统计结果
where 
  // 统计符合以下条件的控制流节点数量：
  // 节点所在的基本块经PointsTo分析判定为不可达状态
  deadBlockTotal = count(ControlFlowNode flowNode | 
    not PointsToInternal::reachableBlock(flowNode.getBasicBlock(), _)
  )
select deadBlockTotal  // 输出不可达基本块的总计数值