/**
 * @name Identification of incomplete task indicators in code comments
 * @description Detects comments that include 'TODO' or 'TO DO' markers, which typically signify
 *              unfinished code sections that may accumulate in a codebase over development cycles.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 *       external/cwe/cwe-546
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/todo-comment
 */

import python

from Comment incompleteTaskComment
where exists(string commentContent |
    commentContent = incompleteTaskComment.getText() and
    (commentContent.matches("%TODO%") or commentContent.matches("%TO DO%"))
)
select incompleteTaskComment, incompleteTaskComment.getText()