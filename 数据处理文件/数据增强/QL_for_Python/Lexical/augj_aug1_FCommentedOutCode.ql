/**
 * @name Lines of commented-out code in files
 * @description Identifies and quantifies commented-out code lines across Python source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import CodeQL modules for Python analysis and lexical processing of commented code
import python
import Lexical.CommentedOutCode

// Define variables to represent source files and their associated commented code line counts
from File targetFile, int commentedCodeLineCount
where 
    // Compute the total count of valid commented code lines for each file
    commentedCodeLineCount = count(CommentedOutCodeLine codeCommentLine | 
        // Ensure the commented line belongs to the current file
        codeCommentLine.getLocation().getFile() = targetFile and
        // Exclude lines that might be example code
        not codeCommentLine.maybeExampleCode())
// Generate results showing each file and its commented code line count, sorted by count in descending order
select targetFile, commentedCodeLineCount order by commentedCodeLineCount desc