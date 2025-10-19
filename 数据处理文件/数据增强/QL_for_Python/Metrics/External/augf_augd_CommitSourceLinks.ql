/**
 * @name 源代码提交链接
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 导入Python分析模块，提供Python代码分析能力
import python
// 导入外部版本控制模块，支持版本控制相关操作
import external.VCS

// 声明查询变量：提交对象和文件对象
from Commit commit, File file
// 过滤条件：
// 1. 文件必须来自源代码（非生成文件）
// 2. 文件必须是当前提交的受影响文件之一
where 
  file.fromSource() and 
  file = commit.getAnAffectedFile()
// 输出结果：提交的修订版本号和对应的文件
select commit.getRevisionName(), file