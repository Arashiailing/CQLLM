/**
 * @name Number of tests
 * @description The number of test methods defined in a module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// 导入Python语言库
import python
// 导入用于过滤测试的库
import semmle.python.filters.Tests

// 从模块和整数类型中选择数据
from Module m, int n
// 条件：n等于严格计数的测试方法，这些测试方法的封闭模块是m
where n = strictcount(Test test | test.getEnclosingModule() = m)
// 选择模块文件和测试数量，并按测试数量降序排列
select m.getFile(), n order by n desc
