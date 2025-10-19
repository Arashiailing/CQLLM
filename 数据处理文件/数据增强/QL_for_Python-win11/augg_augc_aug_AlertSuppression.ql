/**
 * @name Alert suppression
 * @description Provides detailed information about alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents single-line comments with location tracking capabilities
class LineComment instanceof P::Comment {
  // Verify comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve text content of the comment
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Represents AST nodes with location tracking capabilities
class CodeNode instanceof P::AstNode {
  // Verify node matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Return string representation of the AST node
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<CodeNode, LineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents noqa-style suppression comments
class NoqaStyleSuppression extends SuppressionComment instanceof LineComment {
  // Initialize by matching noqa comment pattern
  NoqaStyleSuppression() {
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Match comment location and enforce line-start position
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}