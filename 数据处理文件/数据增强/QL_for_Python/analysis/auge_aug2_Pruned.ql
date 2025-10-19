import python  // 导入Python代码分析框架，提供语法解析和语义分析功能
import semmle.python.pointsto.PointsTo  // 导入指向分析模块，用于变量引用追踪和代码可达性分析

// 此查询旨在识别Python代码中的不可达基本块数量
// 不可达基本块指程序执行流程中永远不会被访问的代码片段，通常表示存在死代码
from int deadCodeBlockCount  // 声明整型变量，用于存储统计结果
where 
  // 计算所有不可达基本块的总数
  deadCodeBlockCount = count(ControlFlowNode flowNode | 
    // 筛选条件：定位所有不可达的基本块
    // PointsToInternal::reachableBlock() 方法用于判断基本块在程序执行中是否可达
    not PointsToInternal::reachableBlock(flowNode.getBasicBlock(), _)
  )
select deadCodeBlockCount  // 输出不可达基本块的总数