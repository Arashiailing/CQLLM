import python  // Python语言分析模块，提供语法树和语义模型支持
import semmle.python.pointsto.PointsTo  // 指向分析模块，用于变量引用关系和代码可达性分析

// 本查询旨在检测Python代码中的不可达基本块（死代码）
// 不可达基本块指程序执行过程中永远不会被访问的代码区域
// 这些死代码通常源于逻辑错误、冗余条件分支或未使用的代码路径
// 识别并移除不可达代码有助于提升代码质量并降低潜在安全风险
from int deadCodeBlockCount  // 声明整型变量，用于统计不可达基本块的总数
where 
  // 计算不可达基本块数量
  // 遍历所有控制流节点，检查其所属基本块的可达性
  deadCodeBlockCount = count(ControlFlowNode cfgNode | 
    // 筛选条件：确定哪些基本块是不可达的
    // PointsToInternal::reachableBlock() 方法评估基本块在程序执行中是否可达
    // 返回false表示该基本块为不可达状态
    not PointsToInternal::reachableBlock(cfgNode.getBasicBlock(), _)
  )
select deadCodeBlockCount  // 输出统计结果：不可达基本块的总数