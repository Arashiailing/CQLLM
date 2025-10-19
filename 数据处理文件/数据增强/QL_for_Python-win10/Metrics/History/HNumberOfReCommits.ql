/**
 * @name Number of re-commits for each file
 * @description A re-commit is taken to mean a commit to a file that was touched less than five days ago.
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 导入Python库和外部版本控制系统（VCS）库
import python
import external.VCS

// 定义一个谓词函数，用于判断两个提交是否在指定范围内
predicate inRange(Commit first, Commit second) {
  // 检查两个提交是否影响同一个文件，并且不是同一个提交
  first.getAnAffectedFile() = second.getAnAffectedFile() and
  first != second and
  // 存在一个整数n，使得n是两个提交之间的天数，并且在0到5天之间
  exists(int n |
    n = first.getDate().daysTo(second.getDate()) and
    n >= 0 and
    n < 5
  )
}

// 定义一个函数，计算某个文件的重新提交次数
int recommitsForFile(File f) {
  // 初始化结果变量
  result =
    // 统计满足条件的提交数量
    count(Commit recommit |
      // 提交影响了指定的文件
      f = recommit.getAnAffectedFile() and
      // 存在一个先前的提交，使得当前提交与先前提交在指定范围内
      exists(Commit prev | inRange(prev, recommit))
    )
}

// 从模块m中选择数据
from Module m
// 条件：模块m有代码行数的度量数据
where exists(m.getMetrics().getNumberOfLinesOfCode())
// 选择模块m和该模块文件的重新提交次数
select m, recommitsForFile(m.getFile())
