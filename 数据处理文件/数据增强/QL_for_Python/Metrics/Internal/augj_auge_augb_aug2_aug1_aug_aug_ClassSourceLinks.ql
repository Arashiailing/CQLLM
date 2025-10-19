/**
 * @name Python类定义与源文件关联映射
 * @description 构建Python类定义与其源文件之间的映射关系，追踪每个类定义的物理位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 主查询：从代码库中提取所有Python类及其对应的源文件
from Class cls, File srcFile
// 关联条件：确保源文件变量确实包含当前类定义的物理位置
where srcFile = cls.getLocation().getFile()
// 结果输出：返回类定义对象及其所属源文件，建立类-文件映射关系
select cls, srcFile