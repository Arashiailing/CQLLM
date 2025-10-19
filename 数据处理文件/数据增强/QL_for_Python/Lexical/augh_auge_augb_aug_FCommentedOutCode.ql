/**
 * @name Commented-out code lines per file
 * @description Counts the number of lines containing commented-out code in each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required modules for Python language analysis and commented code detection
import python
import Lexical.CommentedOutCode

// For each source file, determine the count of non-example commented code lines
from File sourceFile, int commentedCodeCount
where 
    // A commented line is relevant if it belongs to the file and is not example code
    commentedCodeCount = count(CommentedOutCodeLine commentedLine | 
        commentedLine.getLocation().getFile() = sourceFile and
        not commentedLine.maybeExampleCode())
// Output files with their commented code counts, sorted highest to lowest
select sourceFile, commentedCodeCount order by commentedCodeCount desc