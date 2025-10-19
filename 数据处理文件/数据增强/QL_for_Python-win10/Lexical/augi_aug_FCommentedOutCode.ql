/**
 * @name Lines of commented-out code in files
 * @description Calculates the number of lines of commented out code in each Python file,
 *              excluding lines that are identified as example code.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python language support and lexical analysis for commented code
import python
import Lexical.CommentedOutCode

// Define variables to represent the source file and the count of commented-out code lines
from File sourceFile, int commentedLineCount
where 
    // Calculate the number of commented-out lines in each file, excluding example code
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        not commentedLine.maybeExampleCode() and 
        commentedLine.getLocation().getFile() = sourceFile)
select 
    // Output the files along with their commented code line counts, sorted from highest to lowest
    sourceFile, commentedLineCount 
order by 
    commentedLineCount desc