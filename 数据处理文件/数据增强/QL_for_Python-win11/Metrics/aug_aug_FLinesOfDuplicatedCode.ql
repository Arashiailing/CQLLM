/**
 * @deprecated  // 标记此查询为已弃用状态，不推荐继续使用
 * @name Duplicated lines in files  // 查询标题：文件内重复行统计
 * @description Calculates and quantifies the total count of lines (encompassing code, 
 *              comments, and whitespace) that appear more than once across the codebase.  // 功能描述：计算并量化代码库中多次出现的行总数（包括代码、注释和空白行）
 * @kind treemap  // 可视化展示形式：树状图
 * @treemap.warnOn highValues  // 高数值预警机制
 * @metricType file  // 指标评估目标：文件级别
 * @metricAggregate avg sum max  // 统计聚合方法：平均、总和、最大值
 * @tags testability  // 分类标签：可测试性
 * @id py/duplicated-lines-in-files  // 查询唯一标识符：py/duplicated-lines-in-files
 */

import python  // 引入Python代码分析模块

// 定义主查询逻辑：检索分析目标文件及其重复行度量值
from File fileToAnalyze, int repetitionCount
where 
  // 占位条件：无实际过滤逻辑（保留原始设计意图）
  none()
// 输出结果：文件对象与重复行数，按重复度降序排列
select fileToAnalyze, repetitionCount order by repetitionCount desc