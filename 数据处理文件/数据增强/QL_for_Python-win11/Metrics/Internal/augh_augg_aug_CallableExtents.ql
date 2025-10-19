/**
 * @name 可调用对象的范围
 * @description 识别并列出Python代码库中的所有可调用实体，
 *              提供它们的位置信息和可调用对象本身。
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 导入Python分析库以启用代码检查
import python

// 定义变量表示所有可调用实体（函数、方法等）
from Function callableEntity

// 输出每个可调用实体的位置信息和实体本身
select callableEntity.getLocation(), callableEntity