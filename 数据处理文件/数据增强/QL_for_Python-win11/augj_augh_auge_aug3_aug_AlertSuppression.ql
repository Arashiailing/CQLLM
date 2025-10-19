/**
 * @name Alert Suppression Information
 * @description Provides comprehensive details about alert suppressions in Python codebases.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Check if node matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Return string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Check if comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Retrieve comment text content
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

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
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Extract location details from comment
    exists(int commentBeginLine, int commentFinishLine, int commentFinishColumn |
      this.hasLocationInfo(filePath, commentBeginLine, _, commentFinishLine, commentFinishColumn) and
      // Match coverage boundaries to comment location
      beginLine = commentBeginLine and
      finishLine = commentFinishLine and
      beginColumn = 1 and
      finishColumn = commentFinishColumn
    )
  }
}