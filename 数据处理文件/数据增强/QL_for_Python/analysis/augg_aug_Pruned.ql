import python  // Python语言分析模块，提供语法树和基础模型
import semmle.python.pointsto.PointsTo  // 引用关系分析模块，用于追踪变量和对象的引用链

// 统计Python代码中无法被执行到的基本块数量
// 这些基本块在控制流图中从程序入口点无法到达，通常表示死代码
from int deadBlockCount  // 声明变量用于存储不可达基本块的统计结果
where 
  // 计算满足条件的控制流节点数量：
  // 通过PointsTo分析确定节点所在的基本块在程序执行过程中不可达
  deadBlockCount = count(ControlFlowNode flowNode | 
    not PointsToInternal::reachableBlock(flowNode.getBasicBlock(), _)
  )
select deadBlockCount  // 输出不可达基本块的统计总数