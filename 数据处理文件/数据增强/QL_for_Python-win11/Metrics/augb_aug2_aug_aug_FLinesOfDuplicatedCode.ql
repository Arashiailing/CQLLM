/**
 * @deprecated  // 此查询已弃用，建议使用更新的替代方案
 * @name File line duplication analysis  // 查询名称：文件行重复分析
 * @description Calculates and quantifies the number of duplicate lines 
 *              present in each file across the entire codebase, 
 *              encompassing code, comments, and whitespace.  // 功能描述：计算并量化整个代码库中每个文件存在的重复行数量，包括代码、注释和空白
 * @kind treemap  // 可视化类型：树状图展示
 * @treemap.warnOn highValues  // 高值警告设置
 * @metricType file  // 指标类型：文件级别度量
 * @metricAggregate avg sum max  // 聚合方式：平均值、总和、最大值
 * @tags testability  // 适用标签：可测试性相关
 * @id py/duplicated-lines-in-files  // 查询标识符：py/duplicated-lines-in-files
 */

import python  // 导入Python代码分析模块

// 主查询逻辑：识别包含重复行的源文件并计算重复行数
from File sourceFile, int repetitionCount
where 
  // 查询条件占位符（保留原始查询结构）
  none()
// 输出结果：源文件及其对应的重复行计数，按重复数量降序排列
select sourceFile, repetitionCount order by repetitionCount desc