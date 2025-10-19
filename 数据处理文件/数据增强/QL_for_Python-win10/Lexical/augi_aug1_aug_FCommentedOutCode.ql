/**
 * @name Lines of commented-out code in files
 * @description Quantifies and presents the count of lines containing commented-out code for each Python file.
 *              This metric excludes lines that are identified as potential example code to avoid false positives.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required modules for Python code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Primary query to analyze commented code across Python files
from File pythonFile, int commentedCodeLines
where 
    // Compute the aggregate count of commented-out code lines for each file,
    // filtering out lines that represent example code
    commentedCodeLines = count(CommentedOutCodeLine codeLine | 
        // Exclude lines that are likely example code
        not codeLine.maybeExampleCode() and 
        // Ensure the line belongs to the current file being analyzed
        codeLine.getLocation().getFile() = pythonFile)
// Generate output showing each Python file with its corresponding commented code line count,
// ordered from highest to lowest to prioritize files needing attention
select pythonFile, commentedCodeLines order by commentedCodeLines desc