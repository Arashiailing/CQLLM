/**
 * @name Python 类定义源文件映射
 * @description 定位 Python 项目中的所有类定义，并映射到各自的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查询 Python 代码库中的所有类定义，并识别每个类定义所在的源文件
// 利用 getLocation() 方法提取类定义的位置信息，然后通过 getFile() 获取对应的源文件对象
from Class pythonClass
where exists(File sourceFile | sourceFile = pythonClass.getLocation().getFile())
// 返回类定义实例及其关联的源文件，为代码审查和依赖追踪提供支持
select pythonClass, pythonClass.getLocation().getFile()