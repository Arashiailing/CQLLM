/**
 * @name Lines of commented-out code in files
 * @description Detects and counts lines containing commented-out code across source files,
 *              excluding lines that might represent example code
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import CodeQL modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Query to identify source files and quantify their commented-out code lines
from File sourceFile, int commentedLineCount
where 
    // Count the number of commented-out code lines in each file
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        // Exclude lines that could be example code snippets
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line is associated with the current file
        commentedLine.getLocation().getFile() = sourceFile)
// Return results displaying files and their respective commented code line counts,
// sorted in descending order by the count
select sourceFile, commentedLineCount order by commentedLineCount desc