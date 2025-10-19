/**
 * @name Commented-out code lines per file
 * @description Calculates the total number of commented-out code lines (excluding examples) for each Python source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python code analysis and detection of commented-out code
import python
import Lexical.CommentedOutCode

// For each Python source file, count the lines containing commented-out code (excluding examples)
from File targetFile, int commentedLinesCount
where 
    // Calculate the count of commented-out code lines that are not example code
    commentedLinesCount = count(CommentedOutCodeLine commentedOutLine | 
        // Ensure the commented line belongs to the current file
        commentedOutLine.getLocation().getFile() = targetFile and
        // Exclude lines that might be example code
        not commentedOutLine.maybeExampleCode())
// Display the files and their respective commented-out code line counts, sorted in descending order
select targetFile, commentedLinesCount order by commentedLinesCount desc