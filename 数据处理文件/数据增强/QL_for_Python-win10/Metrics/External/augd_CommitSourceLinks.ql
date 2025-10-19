/**
 * @name 源代码提交链接
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 导入Python库，提供Python代码分析功能
import python
// 导入外部版本控制（VCS）库，用于版本控制相关操作
import external.VCS

// 从提交和文件中获取数据
from Commit commitObj, File fileObj
// 条件：文件来自源代码并且文件是提交所影响的文件之一
where 
  fileObj.fromSource() and 
  fileObj = commitObj.getAnAffectedFile()
// 选择提交的修订名称和文件
select commitObj.getRevisionName(), fileObj