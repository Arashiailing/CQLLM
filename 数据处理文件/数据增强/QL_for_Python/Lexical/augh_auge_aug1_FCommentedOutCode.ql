/**
 * @name File-level commented code line statistics
 * @description Analyzes and reports the count of lines containing commented-out code across Python files
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files */

// Import required CodeQL modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define variables representing Python source files and their commented code line counts
from File sourceFile, int totalCommentedLines

// For each Python file, calculate the number of lines containing commented-out code,
// excluding potential example code snippets or documentation
where 
    totalCommentedLines = count(CommentedOutCodeLine commentedLine | 
        // Associate each commented line with its source file
        commentedLine.getLocation().getFile() = sourceFile and
        // Filter out lines that might be example code or documentation
        not commentedLine.maybeExampleCode()
    )

// Output results showing each file path along with its commented code line count,
// sorted by count in descending order to prioritize files with the most commented code
select sourceFile, totalCommentedLines order by totalCommentedLines desc