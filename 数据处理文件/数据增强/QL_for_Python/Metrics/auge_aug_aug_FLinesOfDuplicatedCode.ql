/**
 * @deprecated  // 标识此查询为已弃用，建议使用替代方案
 * @name Duplicated lines in files  // 查询名称：文件内重复行分析
 * @description Quantifies duplicate line occurrences across the codebase by counting 
 *              all lines (including code, comments, and whitespace) that appear 
 *              multiple times within individual files.  // 功能说明：量化代码库中重复行出现次数，
 *              统计单个文件内多次出现的所有行（包括代码、注释和空白行）
 * @kind treemap  // 可视化类型：树状图展示
 * @treemap.warnOn highValues  // 高值触发警告机制
 * @metricType file  // 指标类型：文件级别度量
 * @metricAggregate avg sum max  // 聚合函数：平均值、总和、最大值
 * @tags testability  // 标签分类：可测试性相关
 * @id py/duplicated-lines-in-files  // 唯一标识符：py/duplicated-lines-in-files
 */

import python  // 导入Python语言分析模块

// 主查询：识别目标文件并计算其重复行度量
from File targetFile, int lineDuplicationMetric
where 
  // 查询条件占位符：当前无实际过滤逻辑
  // （保留原始设计结构，为未来扩展预留接口）
  none()
// 结果输出：返回文件对象及其重复行计数，按重复度降序排列
select targetFile, lineDuplicationMetric order by lineDuplicationMetric desc