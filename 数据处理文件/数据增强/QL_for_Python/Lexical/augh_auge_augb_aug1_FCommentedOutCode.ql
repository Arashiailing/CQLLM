/**
 * @name Commented-out code lines in source files
 * @description Identifies and counts lines of commented-out code within source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import CodeQL libraries for Python source code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Query to find source files with commented-out code and calculate the number of such lines
from File srcFile, int commentedCodeLineCount
where 
    // Compute the total count of commented-out code lines for each file
    commentedCodeLineCount = count(CommentedOutCodeLine commentedLine | 
        // Exclude lines that might be example code
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current source file
        commentedLine.getLocation().getFile() = srcFile)
// Display results showing each source file and its count of commented code lines,
// sorted in descending order by line count
select srcFile, commentedCodeLineCount order by commentedCodeLineCount desc