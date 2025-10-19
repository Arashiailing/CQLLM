/**
 * @name Statistics of commented code lines per file
 * @description Calculates and displays the number of lines containing commented-out code in Python source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required CodeQL libraries for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Declare query variables representing source files and their commented code metrics
from File sourceFile, int commentedLinesCount
// Calculate the total lines of commented code per file, excluding potential example code
where 
    commentedLinesCount = count(CommentedOutCodeLine commentedLine | 
        // Conditions: line must belong to the source file and should not be classified as example code
        commentedLine.getLocation().getFile() = sourceFile and
        not commentedLine.maybeExampleCode()
    )
// Output results mapping each file to its commented code line count, sorted in descending order
select sourceFile, commentedLinesCount order by commentedLinesCount desc