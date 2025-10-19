/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Verify node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Return string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Verify comment matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Retrieve text content of the comment
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class identifies comments that follow the noqa format and defines how they suppress alerts.
 * 
 * The noqa comment format is: "# noqa" or "# noqa: <error_codes>"
 * These comments are used to suppress linting warnings on the line they appear.
 */
// Represents noqa-style suppression comments
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
  NoqaSuppressionComment() {
    // Match any comment that contains "noqa" (case-insensitive) optionally followed by a colon and more text
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Match comment location and enforce line-start position
    this.hasLocationInfo(sourceFilePath, beginLine, _, endLine, endColumn) and
    beginColumn = 1
  }
}