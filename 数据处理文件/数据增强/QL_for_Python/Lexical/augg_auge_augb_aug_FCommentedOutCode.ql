/**
 * @name Commented-out code lines per file
 * @description Quantifies commented-out code lines per source file, excluding example code
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

import python
import Lexical.CommentedOutCode

from File sourceFile, int commentedOutCodeCount
where commentedOutCodeCount = count(CommentedOutCodeLine commentedLine | 
        commentedLine.getLocation().getFile() = sourceFile and
        not commentedLine.maybeExampleCode()
)
select sourceFile, commentedOutCodeCount order by commentedOutCodeCount desc