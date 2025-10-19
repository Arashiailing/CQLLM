/**
 * @name Lines of commented-out code in files
 * @description Counts and displays the number of lines containing commented-out code for each Python file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python language support and commented code analysis modules
import python
import Lexical.CommentedOutCode

// Select source files and their corresponding commented code line counts
from File sourceFile, int commentedLinesCount
// Calculate the total number of commented-out code lines per file, excluding potential example code
where commentedLinesCount = count(CommentedOutCodeLine deadCodeLine | 
       // Filter out lines that might be example code
       not deadCodeLine.maybeExampleCode() and 
       // Ensure the commented line belongs to the current source file being analyzed
       deadCodeLine.getLocation().getFile() = sourceFile)
// Output the source file and its commented code line count, sorted in descending order by count
select sourceFile, commentedLinesCount order by commentedLinesCount desc