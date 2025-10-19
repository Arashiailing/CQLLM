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
from File targetFile, int commentedOutLinesCount
// Calculate the total number of commented-out code lines per file
where commentedOutLinesCount = count(CommentedOutCodeLine commentedLine | 
       // Exclude lines that might be example code or documentation
       not commentedLine.maybeExampleCode() and 
       // Ensure the commented line belongs to the current source file
       commentedLine.getLocation().getFile() = targetFile)
// Select source files and their corresponding commented code counts, ordered by count in descending order
select targetFile, commentedOutLinesCount order by commentedOutLinesCount desc