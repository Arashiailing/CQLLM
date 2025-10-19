/**
 * @name File Commented Code Lines
 * @description Identifies and quantifies lines of commented-out code in each source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL modules for Python codebase analysis and commented code identification
import python
import Lexical.CommentedOutCode

// Query to retrieve source files along with their respective counts of commented-out code lines
from File targetFile, int commentedCodeLineCount
// Compute the aggregate count of commented lines per file, filtering out lines that might be example code
where 
    commentedCodeLineCount = count(CommentedOutCodeLine commentedOutLine | 
        commentedOutLine.getLocation().getFile() = targetFile and
        not commentedOutLine.maybeExampleCode())
// Display file paths with their corresponding commented code metrics, arranged in descending order by count
select targetFile, commentedCodeLineCount order by commentedCodeLineCount desc