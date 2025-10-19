/**
 * @name Lines of commented-out code in files
 * @description The number of lines of commented out code per file
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
from File sourceFile, int commentedCodeLineCount
// Calculate the total number of commented-out code lines for each file
where commentedCodeLineCount = count(CommentedOutCodeLine deadCodeLine | 
       // Exclude lines that might be example code
       not deadCodeLine.maybeExampleCode() and 
       // Ensure the commented line belongs to the current source file
       deadCodeLine.getLocation().getFile() = sourceFile)
// Output the source file and its commented code line count, ordered by count in descending order
select sourceFile, commentedCodeLineCount order by commentedCodeLineCount desc