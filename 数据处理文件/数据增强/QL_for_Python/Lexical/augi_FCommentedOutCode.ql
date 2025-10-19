/**
 * @name Lines of commented-out code in files
 * @description The number of lines of commented out code per file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// 导入Python分析库和注释代码检测库
import python
import Lexical.CommentedOutCode

// 定义查询：从源文件和注释行计数中获取数据
from File sourceFile, int commentedLineCount
// 计算每个源文件中被注释掉的代码行数
where 
    // 获取所有非示例代码的注释行
    exists(CommentedOutCodeLine commentedLine | 
        // 确保注释行不是示例代码
        not commentedLine.maybeExampleCode() and
        // 确保注释行属于当前分析的源文件
        commentedLine.getLocation().getFile() = sourceFile
    ) and
    // 统计满足条件的注释行总数
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        not commentedLine.maybeExampleCode() and 
        commentedLine.getLocation().getFile() = sourceFile
    )
// 输出结果：源文件及其对应的注释行计数，按注释行数降序排列
select sourceFile, commentedLineCount order by commentedLineCount desc