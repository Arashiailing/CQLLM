/**
 * @name Lines of commented-out code in files
 * @description Calculates the total number of lines containing commented-out code for each Python file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required CodeQL libraries for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Select source files and their corresponding counts of commented-out lines
from File sourceFile, int commentedLineCount
// Calculate the count of commented lines that are not example code within each file
where 
  commentedLineCount = count(CommentedOutCodeLine commentedLine | 
    // Exclude lines that might be example code
    not commentedLine.maybeExampleCode() and 
    // Ensure the commented line belongs to the current source file
    commentedLine.getLocation().getFile() = sourceFile
  )
// Output the source file and its commented line count, ordered by count in descending order
select sourceFile, commentedLineCount order by commentedLineCount desc