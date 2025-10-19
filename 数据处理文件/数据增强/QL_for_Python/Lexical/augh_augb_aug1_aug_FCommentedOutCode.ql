/**
 * @name Analysis of commented-out code lines in Python files
 * @description Provides a quantitative analysis of lines containing commented-out code 
 *              across Python source files, with intelligent filtering to exclude 
 *              lines that are likely documentation or example code.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python source code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Primary query to identify Python files and calculate their commented code metrics
from File pythonFile, int commentedLineCount
where 
    // Calculate the count of legitimate commented-out code lines for each file
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        // Filter out lines that are likely example code or documentation
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current file being analyzed
        commentedLine.getLocation().getFile() = pythonFile)
// Generate results showing files with their respective commented line counts, 
// ordered by count in descending order to highlight files with most commented code
select pythonFile, commentedLineCount order by commentedLineCount desc