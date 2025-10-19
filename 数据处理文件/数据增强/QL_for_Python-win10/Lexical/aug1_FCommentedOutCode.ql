/**
 * @name Lines of commented-out code in files
 * @description Counts and reports the number of lines containing commented-out code for each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required CodeQL libraries for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Select source files and their corresponding counts of commented-out code lines
from File sourceFile, int commentedLineCount
// Calculate the total number of commented lines in each file, excluding potential example code
where 
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        not commentedLine.maybeExampleCode() and 
        commentedLine.getLocation().getFile() = sourceFile)
// Output the file paths and their commented code counts, sorted in descending order
select sourceFile, commentedLineCount order by commentedLineCount desc