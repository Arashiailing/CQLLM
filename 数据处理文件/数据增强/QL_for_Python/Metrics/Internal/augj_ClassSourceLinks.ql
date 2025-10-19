/**
 * @name Python 类的源代码位置链接
 * @description 查找 Python 代码中所有定义的类，并提供它们的源文件位置信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有 Python 类定义
from Class cls
// 获取每个类及其定义所在的源文件路径
select cls, cls.getLocation().getFile()