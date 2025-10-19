/**
 * @name Lines of commented-out code in files
 * @description Measures the quantity of commented-out code lines within each source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import Python language support and lexical analysis modules for code comment detection
import python
import Lexical.CommentedOutCode

// Declare variables for source files and their corresponding comment line metrics
from File targetFile, int commentedCodeLines
// Compute the total number of commented-out code lines per file, excluding example code
where commentedCodeLines = count(CommentedOutCodeLine codeComment | 
        not codeComment.maybeExampleCode() and 
        codeComment.getLocation().getFile() = targetFile)
// Output the results: files with their comment counts, sorted in descending order
select targetFile, commentedCodeLines order by commentedCodeLines desc