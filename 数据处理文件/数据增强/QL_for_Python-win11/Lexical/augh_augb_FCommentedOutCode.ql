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

// 查询主体：从源文件和注释行数量度量值中选择数据
from File sourceFile, int commentedCodeCount
// 计算条件：统计每个文件中被注释掉的代码行数（排除示例代码）
where commentedCodeCount = count(CommentedOutCodeLine deadCodeLine | 
       // 排除可能是示例代码的注释行
       not deadCodeLine.maybeExampleCode() and 
       // 确保注释行属于当前分析的源文件
       deadCodeLine.getLocation().getFile() = sourceFile)
// 输出结果：选择源文件和对应的注释行数量，并按注释行数量降序排列
select sourceFile, commentedCodeCount order by commentedCodeCount desc