/**
 * @name Lines of commented-out code in files
 * @description Quantifies commented-out code lines per Python file, excluding example code lines.
 *              Results are presented as a treemap to highlight files with excessive commented code.
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
    // Identify non-example commented code lines per file
    commentedCodeLineCount = count(CommentedOutCodeLine codeLine | 
        not codeLine.maybeExampleCode() and 
        codeLine.getLocation().getFile() = targetFile)
// Output files sorted by descending commented code line count
select targetFile, commentedCodeLineCount order by commentedCodeLineCount desc