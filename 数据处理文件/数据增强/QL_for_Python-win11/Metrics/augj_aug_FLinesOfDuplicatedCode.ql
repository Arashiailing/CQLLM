/**
 * @deprecated  // 标记此查询已弃用，不建议使用
 * @name Duplicated lines in files  // 查询名称：文件中的重复行数
 * @description 计算文件中重复出现的行数（包括代码、注释和空白行）， 
 *              这些行在文件内至少有一个其他位置的重复出现。  // 描述更新为更清晰的表达
 * @kind treemap  // 可视化类型：树状图
 * @treemap.warnOn highValues  // 高数值时触发警告
 * @metricType file  // 度量对象：文件级别
 * @metricAggregate avg sum max  // 聚合方式：平均值、总和、最大值
 * @tags testability  // 标签：可测试性相关
 * @id py/duplicated-lines-in-files  // 唯一标识符：py/duplicated-lines-in-files
 */

import python  // 保留原始Python模块导入

// 定义查询主体：选择目标文件及其重复行数
from File targetFile, int dupLineCount
where 
  none()  // 保持无过滤条件（原始逻辑）
select 
  targetFile,  // 重命名变量：file -> targetFile
  dupLineCount  // 重命名变量：duplicateLineCount -> dupLineCount
order by 
  dupLineCount desc  // 保持按重复行数降序排列