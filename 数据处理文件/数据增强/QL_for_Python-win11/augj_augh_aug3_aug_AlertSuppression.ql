/**
 * @name Alert suppression
 * @description Generates information about alert suppressions for Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents single-line comments with enhanced location tracking
class SingleLineComment instanceof P::Comment {
  // Verify comment location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Extract text content from the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Represents AST nodes with enhanced location tracking
class AstNode instanceof P::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Provide string representation of the node
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
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Extract location details from comment
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Enforce line-start position and match boundaries
      startLine = commentStartLine and
      endLine = commentEndLine and
      startColumn = 1 and
      endColumn = commentEndColumn
    )
  }
}