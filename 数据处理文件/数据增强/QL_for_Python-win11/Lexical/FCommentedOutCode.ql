/**
 * @name Lines of commented-out code in files
 * @description The number of lines of commented out code per file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// 导入Python库和注释掉的代码库
import python
import Lexical.CommentedOutCode

// 从文件f和整数n中选择数据
from File f, int n
// 条件：n等于满足以下条件的注释掉的代码行数c
where n = count(CommentedOutCodeLine c | not c.maybeExampleCode() and c.getLocation().getFile() = f)
// 选择文件f和对应的注释掉的代码行数n，并按n降序排列
select f, n order by n desc
