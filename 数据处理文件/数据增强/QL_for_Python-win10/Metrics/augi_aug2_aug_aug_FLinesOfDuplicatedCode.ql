/**
 * @deprecated  // 此查询已不再维护，建议使用更新的替代方案
 * @name Duplicated lines in files  // 查询名称：文件内重复行检测
 * @description Measures and quantifies line duplication across all files in the repository, 
 *              encompassing code, comments, and whitespace-only lines.  // 功能描述：测量并量化代码库中所有文件的行重复情况，包括代码、注释和纯空白行
 * @kind treemap  // 可视化类型：树状图展示
 * @treemap.warnOn highValues  // 高值警告配置
 * @metricType file  // 指标类型：文件级别度量
 * @metricAggregate avg sum max  // 聚合方式：平均值、总和、最大值
 * @tags testability  // 适用标签：可测试性
 * @id py/duplicated-lines-in-files  // 查询标识符：py/duplicated-lines-in-files
 */

import python  // 导入Python代码分析模块

// 主查询逻辑：检测并统计文件中的重复行数量
from File analyzedFile, int repeatedLineCount
where 
  // 查询条件占位（维持原始查询结构）
  none()
// 输出结果：文件对象及其重复行计数，按重复度从高到低排序
select analyzedFile, repeatedLineCount order by repeatedLineCount desc