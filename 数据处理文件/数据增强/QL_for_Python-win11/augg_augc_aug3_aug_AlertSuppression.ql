/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtils
// Import Python comment processing module
private import semmle.python.Comment as PythonCommentUtils

// Represents AST nodes with location tracking capabilities
class AstNode instanceof PythonCommentUtils::AstNode {
  // Verify node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Provide string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking capabilities
class SingleLineComment instanceof PythonCommentUtils::Comment {
  // Verify comment matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Retrieve comment text content
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AlertSuppressionUtils template
import AlertSuppressionUtils::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents noqa-style suppression comments
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Extract location details from comment
    exists(int commentBeginLine, int commentEndLine, int commentEndColumn |
      // Get comment's location boundaries
      this.hasLocationInfo(sourceFilePath, commentBeginLine, _, commentEndLine, commentEndColumn) and
      // Enforce line-start position and match boundaries
      beginLine = commentBeginLine and
      finishLine = commentEndLine and
      beginColumn = 1 and
      finishColumn = commentEndColumn
    )
  }
}