/**
 * @name Lines of commented-out code in files
 * @description Calculates and displays the count of commented-out code lines per source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary modules for Python language support and lexical analysis of commented code
import python
import Lexical.CommentedOutCode

// Define the main query to find source files and their commented code metrics
from File sourceFile, int commentedLineCount
// Calculate the total number of commented-out lines, excluding example code, for each file
where 
    commentedLineCount = count(CommentedOutCodeLine commentedLine | 
        // Exclude lines that are potentially example code
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current source file
        commentedLine.getLocation().getFile() = sourceFile)
// Output the results: source files with their respective commented code counts, sorted by count in descending order
select sourceFile, commentedLineCount order by commentedLineCount desc