/**
 * @name Lines of commented-out code in files
 * @description Identifies and quantifies lines of commented-out code within Python files,
 *              excluding lines that are likely examples or documentation. This metric
 *              helps identify files that may contain excessive legacy code or temporary
 *              debugging code that should be removed. Results are visualized as a treemap
 *              to highlight files with the highest concentration of commented code.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

import python
import Lexical.CommentedOutCode

from File analyzedFile, int totalCommentedLines
where 
    // Compute the aggregate count of commented-out code lines per file
    // Filtering out lines that are likely documentation or example code
    totalCommentedLines = count(CommentedOutCodeLine commentedOutLine | 
        // Exclude lines identified as potential example code
        not commentedOutLine.maybeExampleCode() and 
        // Ensure the line belongs to the file currently under analysis
        commentedOutLine.getLocation().getFile() = analyzedFile)
// Output results sorted by the volume of commented lines in descending order
// Files with higher concentrations of commented code will be prioritized in the output
select analyzedFile, totalCommentedLines order by totalCommentedLines desc