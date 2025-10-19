/**
 * @name Lines of commented-out code in files
 * @description Analyzes Python files to count lines containing commented-out code,
 *              excluding lines that are likely example code. Results are presented
 *              in a treemap visualization highlighting files with high comment density.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required modules for Python source code analysis and comment detection
import python
import Lexical.CommentedOutCode

// Main analysis: identify and count commented-out code lines in each Python file
from File targetFile, int commentCount
where 
    // Determine the count of commented-out code lines per file,
    // filtering out lines that represent example code
    commentCount = count(CommentedOutCodeLine codeLine | 
        not codeLine.maybeExampleCode() and 
        codeLine.getLocation().getFile() = targetFile)
// Present results: display each file with its commented code line count,
// ordered by count in descending order to prioritize files requiring attention
select targetFile, commentCount order by commentCount desc