/**
 * @name Lines of commented-out code in files
 * @description Identifies and quantifies commented-out code lines in Python source files,
 *              excluding lines that appear to be example code. Results are visualized
 *              as a treemap emphasizing files with significant comment density.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python code analysis and comment detection
import python
import Lexical.CommentedOutCode

// Analysis process: Calculate commented-out code lines per Python file
from File pyFile, int commentedCodeLines
where 
    // Count commented lines that are not example code for each file
    commentedCodeLines = count(CommentedOutCodeLine commentedLine | 
        // Exclude lines that might be example code
        not commentedLine.maybeExampleCode() and 
        // Ensure the line belongs to the current file being analyzed
        commentedLine.getLocation().getFile() = pyFile)
// Output results: Show each file with its commented code line count,
// sorted in descending order to highlight files needing attention
select pyFile, commentedCodeLines order by commentedCodeLines desc