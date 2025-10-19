/**
 * @name Lines of commented-out code in files
 * @description Identifies and counts lines of code that have been commented out in each Python file,
 *              excluding potential example code snippets. This metric helps identify areas where
 *              dead code or temporary code removals may exist.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required Python libraries and commented code analysis module
import python
import Lexical.CommentedOutCode

// Define the main query to analyze commented code lines
from File sourceFile, int commentedLineCount
// Calculate the total number of commented-out code lines for each file
where 
  commentedLineCount = count(CommentedOutCodeLine commentedLine | 
    // Filter out lines that might be example code
    not commentedLine.maybeExampleCode() and 
    // Ensure the commented line belongs to the current file being analyzed
    commentedLine.getLocation().getFile() = sourceFile
  )
// Select the file and its corresponding count of commented-out code lines,
// ordered by count in descending order to highlight files with the most commented code
select sourceFile, commentedLineCount order by commentedLineCount desc