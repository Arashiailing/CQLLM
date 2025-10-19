/**
 * @name Show string representations of Python classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// 遍历代码库中的所有Python类定义
from Class cls
// 输出类对象及其名称作为显示字符串
select cls, cls.getName()