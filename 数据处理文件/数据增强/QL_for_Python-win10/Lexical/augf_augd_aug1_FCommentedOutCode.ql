/**
 * @name Lines of commented-out code in files
 * @description Identifies and quantifies commented-out code lines across source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required CodeQL modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Main query to locate source files containing commented-out code
from File sourceFile, int totalCommentedLines
where 
    // Compute the aggregate count of commented-out code lines per source file
    totalCommentedLines = count(CommentedOutCodeLine commentedOutLine | 
        // Filter out lines that may represent example code
        not commentedOutLine.maybeExampleCode() and 
        // Associate each commented line with its containing source file
        commentedOutLine.getLocation().getFile() = sourceFile)
// Output results displaying source file paths and corresponding commented code line counts
select sourceFile, totalCommentedLines 
// Arrange results in descending order based on the volume of commented code
order by totalCommentedLines desc