import python  // 引入Python语言分析库，为代码分析提供基础功能
import semmle.python.pointsto.PointsTo  // 引入PointsTo分析模块，用于分析变量间的指向关系

// 识别类型推断失败的类，并记录相应的失败原因
from ClassValue inferenceFailedClass, string inferenceFailureCause
where 
  // 检查类型推断是否失败，并捕获失败原因
  Types::failedInference(inferenceFailedClass, inferenceFailureCause)
select inferenceFailedClass, inferenceFailureCause