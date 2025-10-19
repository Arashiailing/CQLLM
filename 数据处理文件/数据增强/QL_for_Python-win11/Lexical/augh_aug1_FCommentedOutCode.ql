/**
 * @name Lines of commented-out code in files
 * @description Provides a quantitative analysis of commented-out code lines across source files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL libraries for Python source code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define variables to represent source files and their respective commented code line counts
from File targetFile, int totalCommentedLines
// Compute the count of non-example commented code lines for each source file
where 
    totalCommentedLines = count(CommentedOutCodeLine codeLine | 
        not codeLine.maybeExampleCode() and 
        codeLine.getLocation().getFile() = targetFile)
// Generate results displaying file paths along with their commented code metrics, ordered by volume
select targetFile, totalCommentedLines order by totalCommentedLines desc