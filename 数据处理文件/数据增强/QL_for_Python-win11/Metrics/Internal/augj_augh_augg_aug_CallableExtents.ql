/**
 * @name Python可调用对象清单
 * @description 本查询用于枚举Python代码库中的全部可调用元素，
 *              包括函数、方法等，并展示它们的源代码位置及对象引用。
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 引入Python分析引擎以支持代码库分析
import python

// 声明变量以捕获所有可调用元素（函数、方法等）
from Function callableElement

// 返回每个可调用元素的源代码位置及元素本身
select callableElement.getLocation(), callableElement