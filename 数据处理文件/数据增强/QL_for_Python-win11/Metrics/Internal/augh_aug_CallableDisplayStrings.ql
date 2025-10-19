/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python代码分析基础模块，提供对Python程序结构的访问接口
import python

// 从代码库中识别所有函数定义
from Function callableObj
// 构造描述性字符串，包含函数类型和具体名称
select callableObj, "Function " + callableObj.getName()