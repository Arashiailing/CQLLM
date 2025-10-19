/**
 * @name Count of commented-out code lines per file
 * @description Calculates the number of commented-out code lines in each source file, 
 *              with example code lines excluded from the count
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

import python
import Lexical.CommentedOutCode

from File targetFile, int commentedCodeLineCount
where 
    commentedCodeLineCount = count(CommentedOutCodeLine excludedCommentLine | 
        excludedCommentLine.getLocation().getFile() = targetFile and
        not excludedCommentLine.maybeExampleCode()
    )
select targetFile, commentedCodeLineCount order by commentedCodeLineCount desc