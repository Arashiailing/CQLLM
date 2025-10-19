/**
 * @name 类的源链接
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从类 `Class` 中选择元素
from Class c
// 选择类 `c` 以及其定义位置的文件路径
select c, c.getLocation().getFile()
