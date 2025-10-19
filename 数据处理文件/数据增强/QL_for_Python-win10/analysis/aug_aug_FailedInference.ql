import python  // 导入Python语言分析模块，为代码分析提供基础支持
import semmle.python.pointsto.PointsTo  // 引入PointsTo分析库，实现对象引用关系分析

// 识别类型推断过程中出现问题的类，并获取相应的失败详情
from ClassValue cls, string reason
where Types::failedInference(cls, reason)
select cls, reason