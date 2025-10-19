/**
 * @deprecated  // 此查询已标记为弃用，建议使用替代方案
 * @name Duplicated lines in files  // 查询名称：文件内重复行分析
 * @description Quantifies duplicate lines across all files in the codebase, 
 *              including code, comments, and whitespace lines.  // 功能描述：量化代码库中所有文件的重复行，包括代码、注释和空白行
 * @kind treemap  // 可视化类型：树状图展示
 * @treemap.warnOn highValues  // 高值警告设置
 * @metricType file  // 指标类型：文件级别度量
 * @metricAggregate avg sum max  // 聚合方式：平均值、总和、最大值
 * @tags testability  // 适用标签：可测试性相关
 * @id py/duplicated-lines-in-files  // 查询标识符：py/duplicated-lines-in-files
 */

import python  // 导入Python代码分析模块

// 主查询体：识别具有重复行的文件并计算重复数量
from File targetFile, int duplicateLineCount
where 
  // 查询条件占位符（保留原始查询结构）
  none()
// 结果输出：文件对象及其重复行计数，按重复度降序排序
select targetFile, duplicateLineCount order by duplicateLineCount desc