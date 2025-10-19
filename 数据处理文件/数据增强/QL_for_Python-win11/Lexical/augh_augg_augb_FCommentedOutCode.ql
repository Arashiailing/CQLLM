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

// Define variables for target files and their dead code metrics
from File targetFile, int deadCodeLineCount
// Calculate the total number of commented-out code lines per file
where 
  // Count all commented-out lines that meet our criteria
  deadCodeLineCount = count(CommentedOutCodeLine commentedOutLine | 
    // Exclude lines that might be example code or documentation
    not commentedOutLine.maybeExampleCode() and 
    // Ensure the commented line belongs to the current target file
    commentedOutLine.getLocation().getFile() = targetFile
  )
// Select target files and their corresponding dead code line counts, ordered by count in descending order
select targetFile, deadCodeLineCount order by deadCodeLineCount desc