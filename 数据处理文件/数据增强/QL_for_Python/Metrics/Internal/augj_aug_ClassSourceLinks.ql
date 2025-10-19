/**
 * @name 类的源链接
 * @description 查找 Python 代码中所有类的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历代码库中的所有 Python 类定义
from Class cls
// 返回类对象及其所在的源文件路径
select cls, cls.getLocation().getFile()