/**
 * @name File-level commented code line statistics
 * @description Analyzes and reports the count of lines containing commented-out code across Python files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL modules for Python code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define query variables for target files and their commented code line counts
from File targetFile, int commentCount
// Compute the total commented code lines per file, filtering out potential example code snippets
where 
    commentCount = count(CommentedOutCodeLine commentedOutLine | 
        // Filter conditions: the line must be in the target file and not be example code
        commentedOutLine.getLocation().getFile() = targetFile and
        not commentedOutLine.maybeExampleCode()
    )
// Generate results showing file paths with their respective commented code counts, ordered by count in descending order
select targetFile, commentCount order by commentCount desc