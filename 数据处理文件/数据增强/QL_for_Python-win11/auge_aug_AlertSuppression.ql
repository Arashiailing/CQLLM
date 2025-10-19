/**
 * @name Alert suppression analysis
 * @description Identifies and analyzes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities for handling suppression annotations
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as P

// Represents AST nodes with enhanced location tracking capabilities
class TrackedAstNode instanceof P::AstNode {
  // Verify if the node's location matches the specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Provide a string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with enhanced location tracking
class TrackedSingleLineComment instanceof P::Comment {
  // Verify if the comment's location matches the specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract the text content of the comment
  string getText() { result = super.getContents() }

  // Provide a string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using the AS template with our tracked nodes
import AS::Make<TrackedAstNode, TrackedSingleLineComment>

/**
 * A Python-specific noqa suppression comment. This annotation is recognized by 
 * both pylint and pyflakes linters, and should be supported by LGTM analysis.
 */
// Represents noqa-style suppression comments in Python code
class PythonNoqaSuppressionComment extends SuppressionComment instanceof TrackedSingleLineComment {
  // Constructor: Identify comments that match the noqa pattern
  PythonNoqaSuppressionComment() {
    TrackedSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the code coverage scope for this suppression annotation
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure the comment is at the beginning of the line and matches the location
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}