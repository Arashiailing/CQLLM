/**
 * @name 可调用对象的源代码链接
 * @description 查找Python代码中的所有可调用对象（函数）及其源文件位置
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 * @tags source-link
 */

import python

// 本查询用于识别代码库中的所有函数定义，并获取它们所在的源文件
// 这有助于理解代码结构并进行源代码导航

// 获取所有函数对象及其位置信息
from Function callableObj, Location funcLocation
where funcLocation = callableObj.getLocation()
select callableObj, funcLocation.getFile()