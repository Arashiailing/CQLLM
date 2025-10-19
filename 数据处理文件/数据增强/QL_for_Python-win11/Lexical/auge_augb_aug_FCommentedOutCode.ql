/**
 * @name Commented-out code lines per file
 * @description Counts the number of lines containing commented-out code in each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules: Python language support and lexical analysis for commented code
import python
import Lexical.CommentedOutCode

// Declare variables for source files and their corresponding commented code metrics
from File targetFile, int commentedLinesTotal
// Compute the aggregate count of commented lines that are not example code for each file
where commentedLinesTotal = count(CommentedOutCodeLine line | 
        line.getLocation().getFile() = targetFile and
        not line.maybeExampleCode())
// Output files along with their commented line counts, ordered by count in descending order
select targetFile, commentedLinesTotal order by commentedLinesTotal desc