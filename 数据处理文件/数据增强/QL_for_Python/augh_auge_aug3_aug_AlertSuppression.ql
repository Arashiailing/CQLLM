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
  // Determine if node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFile, int startLine, int startColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFile, startLine, startColumn, endLine, endColumn)
  }

  // Return string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Determine if comment matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFile, int startLine, int startColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFile, startLine, startColumn, endLine, endColumn)
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
    string sourceFile, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Extract location details from comment
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      this.hasLocationInfo(sourceFile, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Match coverage boundaries to comment location
      startLine = commentStartLine and
      endLine = commentEndLine and
      startColumn = 1 and
      endColumn = commentEndColumn
    )
  }
}