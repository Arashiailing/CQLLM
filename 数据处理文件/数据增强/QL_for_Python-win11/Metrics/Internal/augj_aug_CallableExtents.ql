/**
 * @name 可调用对象范围
 * @description 查询Python代码中所有可调用对象的范围信息
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 导入Python代码分析所需的基础模块
import python

// 声明变量表示所有可调用实体（函数、方法等）
from Function callableEntity

// 返回每个可调用实体的位置信息及其本身
select callableEntity.getLocation(), callableEntity