/**
 * @name Display strings of classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// 检索所有Python类定义并生成其名称的显示字符串
from Class pythonClass
select pythonClass, pythonClass.getName() // 返回类实例及其对应的名称作为显示字符串