/**
 * @name File-based commented code line counter
 * @description Measures the quantity of commented-out code lines in each source file, while intentionally excluding lines that might represent example code
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

import python
import Lexical.CommentedOutCode

from File fileToAnalyze, int commentedLinesTotal
where commentedLinesTotal = count(CommentedOutCodeLine lineOfCommentedCode | 
        lineOfCommentedCode.getLocation().getFile() = fileToAnalyze and
        not lineOfCommentedCode.maybeExampleCode()
)
select fileToAnalyze, commentedLinesTotal order by commentedLinesTotal desc