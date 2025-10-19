/**
 * @name Commented-out code lines per file
 * @description Calculates and displays the total count of non-example commented-out code lines for each source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import required modules: Python language support and lexical analysis utilities for detecting commented code
import python
import Lexical.CommentedOutCode

// Define source file and commented code count variables for analysis
from File sourceFile, int commentedCodeCount
// Filter and count commented code lines that are actual code comments (not examples)
where 
    // Aggregate all commented lines belonging to the current source file
    commentedCodeCount = count(CommentedOutCodeLine commentedLine | 
        // Ensure the commented line is from our target source file
        commentedLine.getLocation().getFile() = sourceFile and
        // Exclude lines that are likely example code or documentation
        not commentedLine.maybeExampleCode()
    )
// Output results showing each file with its corresponding commented code count, sorted by highest count first
select sourceFile, commentedCodeCount order by commentedCodeCount desc