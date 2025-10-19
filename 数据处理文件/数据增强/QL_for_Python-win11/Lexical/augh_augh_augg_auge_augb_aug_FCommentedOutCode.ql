/**
 * @name File-based commented code line counter
 * @description Counts the number of lines containing commented-out code in each source file, excluding lines that could be example code
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

import python
import Lexical.CommentedOutCode

from File sourceFile, int commentedCodeCount
where 
  commentedCodeCount = count(CommentedOutCodeLine commentedLine |
    commentedLine.getLocation().getFile() = sourceFile and
    not commentedLine.maybeExampleCode()
  )
select sourceFile, commentedCodeCount order by commentedCodeCount desc