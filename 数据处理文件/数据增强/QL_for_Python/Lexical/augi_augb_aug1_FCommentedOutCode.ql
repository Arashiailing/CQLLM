/**
 * @name Lines of commented-out code in files
 * @description Detects and measures the number of lines that contain commented-out code within source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL libraries for Python code analysis and commented code identification
import python
import Lexical.CommentedOutCode

// Query to identify source files containing commented-out code and calculate the count of such lines
from File sourceFile, int commentedOutLinesCount
where 
    // Calculate the total number of commented-out code lines in each file, excluding potential example code
    commentedOutLinesCount = count(CommentedOutCodeLine commentedLine | 
        // Filter out lines that could be example code
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line is associated with the current source file
        commentedLine.getLocation().getFile() = sourceFile)
// Output results displaying each source file along with its respective count of commented-out code lines, sorted in descending order
select sourceFile, commentedOutLinesCount order by commentedOutLinesCount desc