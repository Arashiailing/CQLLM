/**
 * @name 类的源链接
 * @description 查找 Python 代码中所有类的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查询所有 Python 类定义及其对应的源文件位置
from Class cls, 
     File sourceFile 
where sourceFile = cls.getLocation().getFile()
select cls, sourceFile