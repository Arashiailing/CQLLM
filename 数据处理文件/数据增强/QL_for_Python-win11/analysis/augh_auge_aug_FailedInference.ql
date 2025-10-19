import python  // 导入Python语言分析库，提供Python代码静态分析的核心功能
import semmle.python.pointsto.PointsTo  // 导入PointsTo分析模块，用于执行对象引用和指向关系分析

// 检测Python代码中类型推断失败的类定义，并提取相关的错误诊断信息
from ClassValue inferenceFailureClass, string diagnosticMessage
where Types::failedInference(inferenceFailureClass, diagnosticMessage)
select inferenceFailureClass, diagnosticMessage