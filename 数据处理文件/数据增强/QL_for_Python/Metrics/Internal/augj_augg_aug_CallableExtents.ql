/**
 * @name 可调用对象范围分析
 * @description 此查询用于全面识别Python代码库中的所有可调用实体，
 *              包括函数、方法等，并提供它们在代码中的精确位置信息
 *              以及可调用对象本身的引用。
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 导入Python语言分析库，为代码库的静态分析提供必要支持
import python

// 从代码库中识别所有可调用实体
from Function callableEntity

// 输出每个可调用实体的位置信息和对象引用
select callableEntity.getLocation(), callableEntity