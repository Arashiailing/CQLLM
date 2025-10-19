/**
 * @name Lines of commented-out code in files
 * @description Identifies and quantifies lines containing commented-out code across source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import CodeQL libraries for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Query to find files with commented-out code and count such lines
from File codeFile, int commentedCodeLines
// Define conditions to identify and count commented-out code lines
where 
    // Count lines that contain commented-out code, excluding potential examples
    commentedCodeLines = count(CommentedOutCodeLine commentedOutLine | 
        // Exclude lines that might be example code
        not commentedOutLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current file
        commentedOutLine.getLocation().getFile() = codeFile)
// Return results showing files and their respective commented code line counts
select codeFile, commentedCodeLines order by commentedCodeLines desc