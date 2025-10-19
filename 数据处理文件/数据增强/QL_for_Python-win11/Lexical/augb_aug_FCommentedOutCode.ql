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

// Define variables representing source files and their comment metrics
from File sourceFile, int commentLineCount
// Calculate the total count of non-example commented lines per file
where commentLineCount = count(CommentedOutCodeLine commentedLine | 
        not commentedLine.maybeExampleCode() and 
        commentedLine.getLocation().getFile() = sourceFile)
// Return files with their comment counts, sorted from highest to lowest
select sourceFile, commentLineCount order by commentLineCount desc