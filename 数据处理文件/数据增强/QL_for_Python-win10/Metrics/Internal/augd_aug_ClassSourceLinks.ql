/**
 * @name 类的源链接
 * @description 识别并定位 Python 代码中所有定义的类的源文件位置
 * @details 此查询遍历代码库中的所有 Python 类，并提供每个类所在的源文件路径信息，
 *          帮助开发者快速定位类定义，便于代码审查和维护
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义变量：从 Python 代码库中识别所有类定义
from Class cls
// 提取结果：获取每个类的源文件位置信息
select cls, cls.getLocation().getFile()