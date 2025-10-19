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

// Define variables representing code files and their commented-out code metrics
from File codeFile, int commentedOutLineCount
// Calculate the total count of non-example commented-out lines per file
where commentedOutLineCount = count(CommentedOutCodeLine commentedOutLine | 
        not commentedOutLine.maybeExampleCode() and 
        commentedOutLine.getLocation().getFile() = codeFile)
// Return files with their commented-out code counts, sorted from highest to lowest
select codeFile, commentedOutLineCount order by commentedOutLineCount desc