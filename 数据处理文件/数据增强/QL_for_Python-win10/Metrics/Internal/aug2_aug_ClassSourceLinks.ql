/**
 * @name 类的源链接
 * @description 识别并定位 Python 代码中定义的所有类，提供其源文件的完整路径信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找所有 Python 类并获取其源文件位置
from Class cls
// 提取类对象及其源文件路径
select cls, cls.getLocation().getFile()