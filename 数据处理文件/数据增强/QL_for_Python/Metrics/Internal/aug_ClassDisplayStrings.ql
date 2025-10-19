/**
 * @name Display strings of classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// 查询所有Python类并展示其名称
from Class cls
select cls, cls.getName() // 返回类对象及其对应的名称作为显示字符串