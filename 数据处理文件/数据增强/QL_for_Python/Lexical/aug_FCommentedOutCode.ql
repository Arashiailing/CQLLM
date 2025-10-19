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

// Select source files and their corresponding commented-out code metrics
from File targetFile, int commentedCodeLines
// Count commented-out lines that are not example code within each file
where commentedCodeLines = count(CommentedOutCodeLine line | 
        not line.maybeExampleCode() and 
        line.getLocation().getFile() = targetFile)
// Return files with their commented code counts, sorted in descending order
select targetFile, commentedCodeLines order by commentedCodeLines desc