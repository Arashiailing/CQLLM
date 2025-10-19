/**
 * @name Lines of commented-out code in files
 * @description Calculates and displays the number of lines containing commented-out code for each Python file.
 *              Lines identified as potential example code are excluded from the count.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define the main query to analyze commented-out code in Python files
from File sourceFile, int commentedLineCount
where 
    // Calculate the total number of commented-out code lines per file,
    // excluding lines that might be example code
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        not commentedLine.maybeExampleCode() and 
        commentedLine.getLocation().getFile() = sourceFile)
// Output the results: each file with its corresponding count of commented-out lines,
// sorted in descending order to highlight files with the most commented code
select sourceFile, commentedLineCount order by commentedLineCount desc