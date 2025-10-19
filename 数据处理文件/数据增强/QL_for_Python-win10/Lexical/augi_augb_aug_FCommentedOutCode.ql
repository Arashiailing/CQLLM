/**
 * @name Lines of commented-out code in files
 * @description Counts the number of lines containing commented-out code in each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python language analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define variables for code files and their commented code line counts
from File codeFile, int commentedOutCodeLines
// Calculate the count of commented lines, excluding potential example code
where commentedOutCodeLines = count(CommentedOutCodeLine commentedCodeLine | 
        not commentedCodeLine.maybeExampleCode() and 
        commentedCodeLine.getLocation().getFile() = codeFile)
// Return files and their commented code line counts, ordered by count in descending order
select codeFile, commentedOutCodeLines order by commentedOutCodeLines desc