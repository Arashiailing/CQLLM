/**
 * @name Lines of commented-out code in files
 * @description The number of lines of commented out code per file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// 引入Python语言支持库和注释代码分析功能模块
import python
import Lexical.CommentedOutCode

// 主查询：从源文件和注释代码行数量统计值中提取数据
from File targetFile, int deadCodeLineCount
// 过滤条件：计算每个文件中被注释掉的代码行总数（不包含示例代码）
where deadCodeLineCount = count(CommentedOutCodeLine commentedLine | 
       // 排除可能是示例代码的注释行
       not commentedLine.maybeExampleCode() and 
       // 确保注释行属于当前正在分析的源文件
       commentedLine.getLocation().getFile() = targetFile)
// 结果输出：选择目标文件及其对应的注释代码行数，并按注释行数量从高到低排序
select targetFile, deadCodeLineCount order by deadCodeLineCount desc