/**
 * @name Count of commented-out code lines by file
 * @description Calculates and presents the total lines of commented-out code for each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary Python libraries and commented code detection functionality
import python
import Lexical.CommentedOutCode

// Select data from source files and their corresponding commented line counts
from File sourceFile, int commentedLineCount
// Condition: commentedLineCount equals the number of commented lines that meet specific criteria
where 
  // Count all commented lines in the file that are not example code
  commentedLineCount = count(CommentedOutCodeLine commentedLine | 
    // Exclude lines that might be example code
    not commentedLine.maybeExampleCode() and 
    // Ensure the commented line belongs to the current file
    commentedLine.getLocation().getFile() = sourceFile)
// Select the source file and its commented line count, ordered by count in descending order
select sourceFile, commentedLineCount order by commentedLineCount desc