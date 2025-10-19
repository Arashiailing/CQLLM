import python  // 引入Python语言分析支持库，为代码分析提供基础功能
import semmle.python.pointsto.PointsTo  // 引入指向分析模块，提供变量指向关系的分析能力

// 识别类型推断过程中出现问题的类，并获取相关失败信息
from ClassValue problematicClass, string inferenceFailureCause
where Types::failedInference(problematicClass, inferenceFailureCause)
select problematicClass, inferenceFailureCause