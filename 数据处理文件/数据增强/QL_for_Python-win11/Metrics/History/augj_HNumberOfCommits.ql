/**
 * @name Number of commits
 * @description Number of commits
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// 引入 Python 分析模块，提供 Python 代码分析功能
import python
// 引入外部版本控制系统(VCS)分析模块，支持版本历史数据分析
import external.VCS

// 遍历所有提交记录，排除非人工提交的记录，确保只统计真实的代码变更
from Commit commitRecord
where not artificialChange(commitRecord)
// 提取提交的修订标识并计数，用于生成提交数量统计的树状图
select commitRecord.getRevisionName(), 1