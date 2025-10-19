/**
 * @name Lines of commented-out code in files
 * @description Measures the quantity of commented-out code lines within each source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary Python language modules and lexical analysis for comment detection
import python
import Lexical.CommentedOutCode

// Define variables representing source files and their respective commented code metrics
from File sourceFile, int numCommentedLines
// Calculate the total count of commented-out code lines in each file, excluding example code snippets
where numCommentedLines = count(CommentedOutCodeLine commentLine | 
        not commentLine.maybeExampleCode() and 
        commentLine.getLocation().getFile() = sourceFile)
// Display results: each file with its corresponding comment count, sorted by count in descending order
select sourceFile, numCommentedLines order by numCommentedLines desc