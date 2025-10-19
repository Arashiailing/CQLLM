/**
 * @name Lines of commented-out code in files
 * @description Calculates and displays the count of commented-out code lines in each Python file.
 *              This metric helps identify files with excessive commented code, which may impact maintainability.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python language support and analysis of commented-out code
import python
import Lexical.CommentedOutCode

// Identify source files and calculate their commented-out code metrics
from File sourceFile, int commentedLineCount
where 
    // Count all commented-out lines that are not example code within each file
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        not commentedLine.maybeExampleCode() and 
        commentedLine.getLocation().getFile() = sourceFile)
// Output the files with their respective commented code counts, sorted in descending order
select sourceFile, commentedLineCount order by commentedLineCount desc