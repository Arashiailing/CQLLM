/**
 * @name Lines of commented-out code in files
 * @description The number of lines of commented out code per file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// 导入Python语言支持库和注释代码分析模块
import python
import Lexical.CommentedOutCode

// 从源文件targetFile和注释行数量度量值deadCodeMetric中选择数据
from File targetFile, int deadCodeMetric
// 条件：deadCodeMetric等于满足以下条件的注释行commentedLine的总数
where deadCodeMetric = count(CommentedOutCodeLine commentedLine | 
       // 排除可能是示例代码的注释行
       not commentedLine.maybeExampleCode() and 
       // 确保注释行属于当前分析的源文件
       commentedLine.getLocation().getFile() = targetFile)
// 选择源文件targetFile和对应的注释行数量deadCodeMetric，并按deadCodeMetric降序排列
select targetFile, deadCodeMetric order by deadCodeMetric desc