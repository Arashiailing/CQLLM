/**
 * @name Display class names
 * @description Shows the name of each class in the codebase
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// 选取所有类定义
from Class targetClass
// 返回类对象及其名称字符串
select targetClass, targetClass.getName()