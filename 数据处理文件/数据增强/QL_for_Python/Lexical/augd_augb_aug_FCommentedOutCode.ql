/**
 * @name Lines of commented-out code in files
 * @description Counts the number of lines containing commented-out code for each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python language support and lexical analysis of commented code
import python
import Lexical.CommentedOutCode

// Declare variables representing target files and their respective commented code line counts
from File targetFile, int commentedCodeLines
// Filter files and calculate the total count of non-example commented code lines per file
where commentedCodeLines = count(CommentedOutCodeLine commentedOutLine | 
        // Exclude lines that might be example code
        not commentedOutLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current file being analyzed
        commentedOutLine.getLocation().getFile() = targetFile)
// Output the files with their commented code line counts, sorted in descending order
select targetFile, commentedCodeLines order by commentedCodeLines desc