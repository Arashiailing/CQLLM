/**
 * @name Alert suppression detection
 * @description Identifies and reports alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities for handling suppression annotations
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtils
// Import Python comment processing module for analyzing source code comments
private import semmle.python.Comment as PythonCommentUtils

// Represents AST nodes enhanced with location tracking capabilities
class TrackedAstNode instanceof PythonCommentUtils::AstNode {
  // Verify node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Provide string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments enhanced with location tracking capabilities
class TrackedSingleLineComment instanceof PythonCommentUtils::Comment {
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

// Generate suppression relationships using AlertSuppressionUtils template with tracked nodes
import AlertSuppressionUtils::Make<TrackedAstNode, TrackedSingleLineComment>

/**
 * A noqa-style suppression comment. Both pylint and pyflakes respect this convention,
 * making it essential for lgtm to recognize and process these suppressions appropriately.
 */
// Represents suppression comments following the noqa convention
class NoqaStyleSuppression extends SuppressionComment instanceof TrackedSingleLineComment {
  // Initialize by identifying comments matching the noqa pattern
  NoqaStyleSuppression() {
    TrackedSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the code coverage scope for this suppression
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Extract and utilize location details from the comment
    exists(int startLine, int endLine, int endColumn |
      // Obtain the comment's location boundaries
      this.hasLocationInfo(sourceFilePath, startLine, _, endLine, endColumn) and
      // Set the coverage to start at the beginning of the line and match the comment's boundaries
      beginLine = startLine and
      finishLine = endLine and
      beginColumn = 1 and
      finishColumn = endColumn
    )
  }
}