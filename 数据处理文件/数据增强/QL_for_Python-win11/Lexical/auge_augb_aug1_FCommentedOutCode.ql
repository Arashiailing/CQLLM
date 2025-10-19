/**
 * @name Lines of commented-out code in files
 * @description Detects and measures the quantity of lines containing commented-out code within source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL libraries for Python source code analysis and commented code identification
import python
import Lexical.CommentedOutCode

// Main query to identify source files containing commented-out code and calculate the count of such lines
from File sourceFile, int commentedLineCount
where 
    // Calculate the total number of commented-out code lines per file
    commentedLineCount = count(CommentedOutCodeLine commentedCode | 
        // Filter out lines that could potentially be example code
        not commentedCode.maybeExampleCode() and 
        // Ensure the commented line is associated with the current source file
        commentedCode.getLocation().getFile() = sourceFile)
// Output the results displaying each source file and its corresponding count of commented code lines,
// ordered in descending sequence based on the line count
select sourceFile, commentedLineCount order by commentedLineCount desc