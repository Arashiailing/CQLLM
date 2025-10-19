/**
 * @name Lines of commented-out code in files
 * @description Detects and counts lines of commented-out code in source files, excluding potential example code
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL modules for Python source code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Main query that identifies files and quantifies their commented-out code lines
from File sourceFile, int commentedCodeCount
where 
    // Calculate the count of commented-out code lines per file, excluding potential examples
    commentedCodeCount = count(CommentedOutCodeLine commentedLine | 
        // Filter out lines that could be example code
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line is associated with the current file
        commentedLine.getLocation().getFile() = sourceFile)
// Output the results: files and their respective counts of commented-out code lines, ordered by count in descending order
select sourceFile, commentedCodeCount order by commentedCodeCount desc