/**
 * @name Lines of commented-out code in files
 * @description Analyzes Python files to count lines containing commented-out code,
 *              with filtering to exclude lines that represent example code snippets.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Query to calculate and report commented-out code lines per Python file
from File sourceFile, int commentedLinesTotal
where 
    // Calculate the total number of commented-out lines for each file,
    // excluding lines that are likely example code
    commentedLinesTotal = count(CommentedOutCodeLine commentedLine | 
        commentedLine.getLocation().getFile() = sourceFile and
        not commentedLine.maybeExampleCode())
// Output results showing each file with its commented line count,
// sorted in descending order by the count of commented lines
select sourceFile, commentedLinesTotal order by commentedLinesTotal desc