/**
 * @name Lines of commented-out code in files
 * @description The number of lines of commented out code per file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python language support and lexical analysis for commented code
import python
import Lexical.CommentedOutCode

// Define variables for source files and their commented code metrics
from File sourceFile, int commentedCodeCount
// Calculate the total number of commented-out code lines per file
where commentedCodeCount = count(CommentedOutCodeLine deadCodeLine | 
       // Exclude lines that might be example code or documentation
       not deadCodeLine.maybeExampleCode() and 
       // Ensure the commented line belongs to the current source file
       deadCodeLine.getLocation().getFile() = sourceFile)
// Select source files and their corresponding commented code counts, ordered by count in descending order
select sourceFile, commentedCodeCount order by commentedCodeCount desc