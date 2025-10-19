/**
 * @name Lines of commented-out code in files
 * @description This query analyzes Python source files to detect and quantify lines of code
 *              that have been commented out. It excludes lines that are likely example code snippets.
 *              The results help maintainers identify files with potential dead code or temporary
 *              code removals that might need attention.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python language support and commented code detection functionality
import python
import Lexical.CommentedOutCode

// Define the main query to analyze commented code lines
from File fileAnalyzed, int commentedLinesTotal
where 
  // Calculate the total number of commented-out code lines for each file
  commentedLinesTotal = count(CommentedOutCodeLine commentedOutLine | 
    // Exclude lines that might be example code
    not commentedOutLine.maybeExampleCode() and 
    // Ensure the commented line belongs to the file being analyzed
    commentedOutLine.getLocation().getFile() = fileAnalyzed
  )
// Select the file and its corresponding count of commented-out code lines,
// ordered by count in descending order to highlight files with the most commented code
select fileAnalyzed, commentedLinesTotal order by commentedLinesTotal desc