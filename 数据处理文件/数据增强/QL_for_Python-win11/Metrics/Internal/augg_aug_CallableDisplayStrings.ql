/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python语言分析支持库，用于访问Python代码结构元素
import python

// 定义查询范围：选择所有Python函数定义实体
from Function callableObj
// 生成输出结果：函数对象及其对应的描述性字符串
select callableObj, "Function " + callableObj.getName()