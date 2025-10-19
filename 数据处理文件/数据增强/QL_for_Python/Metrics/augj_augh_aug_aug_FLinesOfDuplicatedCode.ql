/**
 * @deprecated  // 此查询已不再维护，建议采用替代方案
 * @name Duplicated lines in files  // 查询名称：文件重复行统计
 * @description Measures the cumulative amount of repeated lines within each file, 
 *              covering source code, comments, and empty lines.  // 功能描述：测量每个文件内重复行的累计数量，包括源代码、注释和空行
 * @kind treemap  // 可视化类型：树状图
 * @treemap.warnOn highValues  // 高值警告机制
 * @metricType file  // 指标范围：文件级别
 * @metricAggregate avg sum max  // 聚合计算：平均值、总和、最大值
 * @tags testability  // 标签：可测试性
 * @id py/duplicated-lines-in-files  // 查询标识：py/duplicated-lines-in-files
 */

import python  // 导入Python语言分析模块

// 主要查询：识别文件并计算其重复行数量指标
from File sourceFile, int lineDuplicationMetric
where 
  // 筛选条件：当前为占位实现，实际检测逻辑尚未完成
  none()
// 结果输出：文件实体与重复行度量，按重复度从高到低排序
select sourceFile, lineDuplicationMetric order by lineDuplicationMetric desc