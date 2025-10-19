import python  // 导入Python语言分析库，提供代码分析的基础功能支持
import semmle.python.pointsto.PointsTo  // 导入PointsTo分析模块，支持变量指向关系的分析

// 检测类型推断失败的类，并捕获对应的失败原因
from ClassValue failedTypeClass, string failureReason
where Types::failedInference(failedTypeClass, failureReason)
select failedTypeClass, failureReason