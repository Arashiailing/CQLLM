/**
 * @name Lines of commented-out code in files
 * @description Identifies and counts the number of lines containing commented-out code in each Python file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python language support and lexical analysis for commented code
import python
import Lexical.CommentedOutCode

// Define variables for source files and their commented code metrics
from File sourceFile, int commentedCodeLineCount
// Calculate the total number of commented-out code lines per file
where 
  // Count all commented-out lines that meet our criteria
  commentedCodeLineCount = count(CommentedOutCodeLine commentedLine | 
    // Ensure the commented line belongs to the current source file
    commentedLine.getLocation().getFile() = sourceFile and
    // Exclude lines that might be example code or documentation
    not commentedLine.maybeExampleCode()
  )
// Select source files and their corresponding commented code line counts, ordered by count in descending order
select sourceFile, commentedCodeLineCount order by commentedCodeLineCount desc