/**
 * @name Display strings of classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// 从所有类中选择
from Class c
// 选择类和类的名称作为显示字符串
select c, c.getName()
