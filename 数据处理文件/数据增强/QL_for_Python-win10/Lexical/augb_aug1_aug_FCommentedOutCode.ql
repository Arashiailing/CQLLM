/**
 * @name Lines of commented-out code in files
 * @description Counts lines with commented-out code in each Python file,
 *              excluding lines that are likely example code.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python analysis and commented code detection modules
import python
import Lexical.CommentedOutCode

// Main query to identify and count commented-out code lines
from File targetFile, int commentedCodeLineCount
where 
    // Count commented-out lines per file, excluding potential example code
    commentedCodeLineCount = count(CommentedOutCodeLine commentedOutLine | 
        not commentedOutLine.maybeExampleCode() and 
        commentedOutLine.getLocation().getFile() = targetFile)
// Display results: files with their commented line counts, sorted by count (descending)
select targetFile, commentedCodeLineCount order by commentedCodeLineCount desc