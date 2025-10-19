/**
 * @deprecated  // 此查询已标记为弃用状态，建议使用替代方案
 * @name Duplicated lines in files  // 查询名称：文件内重复行分析
 * @description Quantifies the aggregate number of duplicate lines within each file, 
 *              including source code, comments, and blank lines.  // 功能描述：量化每个文件中的重复行总数，包括源代码、注释和空行
 * @kind treemap  // 可视化类型：树状图展示
 * @treemap.warnOn highValues  // 高值触发警告机制
 * @metricType file  // 指标作用域：文件级别
 * @metricAggregate avg sum max  // 聚合统计方式：平均值、总和、最大值
 * @tags testability  // 标签分类：可测试性
 * @id py/duplicated-lines-in-files  // 查询唯一标识：py/duplicated-lines-in-files
 */

import python  // 导入Python语言分析模块

// 主查询：识别目标文件并计算其重复行统计指标
from File targetFile, int duplicateLineCount
where 
  // 过滤条件：当前为占位符，未实现具体检测逻辑
  none()
// 结果输出：文件实体与重复行数量，按重复度从高到低排序
select targetFile, duplicateLineCount order by duplicateLineCount desc