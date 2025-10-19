/**
 * @name Lines of commented-out code in files
 * @description Quantifies and presents the number of lines containing commented-out code
 *              in each Python source file. This metric serves as an indicator of code
 *              maintainability, helping developers identify files that may require
 *              refactoring due to excessive commented code.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define the main query to analyze commented code in Python files
from File pythonFile, int commentedCodeLines
where 
    // Calculate the total count of commented-out code lines per file
    // Exclude lines that are likely example code or documentation
    commentedCodeLines = count(CommentedOutCodeLine commentedOutLine | 
        // Filter out example code lines to focus on actual commented-out code
        not commentedOutLine.maybeExampleCode() and 
        // Ensure we only count lines from the current file being analyzed
        commentedOutLine.getLocation().getFile() = pythonFile)
// Display results showing each Python file with its commented code line count
// Sort results in descending order to highlight files with most commented code
select pythonFile, commentedCodeLines order by commentedCodeLines desc