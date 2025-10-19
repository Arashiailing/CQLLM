import python  // 加载Python语言分析的核心库，提供代码语法树和结构化分析能力
import semmle.python.pointsto.PointsTo  // 引入对象引用分析模块，支持运行时对象引用关系的追踪

// 检测类型推断失败的类定义及其相关错误描述
// 该查询用于识别静态分析中类型系统无法准确推断的类，辅助发现类型推断的薄弱环节
from ClassValue clsDef, string errDescription
where Types::failedInference(clsDef, errDescription)
select clsDef, errDescription