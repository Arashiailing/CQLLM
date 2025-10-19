/**
 * @name Alert suppression analysis
 * @description Identifies and analyzes alert suppression mechanisms in Python code,
 *              concentrating on 'noqa' style suppression comments which are commonly used
 *              to disable linter warnings.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for analyzing suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities to extract and process code comments
private import semmle.python.Comment as PythonComment

/**
 * Represents a single-line Python comment with enhanced location tracking capabilities.
 * This class extends the base Comment class to provide more detailed location information.
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves detailed location information for the comment.
   * @param sourceFile - The path to the file containing the comment
   * @param beginLine - The starting line number of the comment
   * @param beginColumn - The starting column number of the comment
   * @param endLine - The ending line number of the comment
   * @param endColumn - The ending column number of the comment
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Inherit location details from parent class
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, endLine, endColumn)
  }

  /**
   * Extracts the text content of the comment, excluding the comment marker.
   * @returns The textual content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of the comment.
   * @returns A string representation of the comment
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a Python AST node with detailed location tracking capabilities.
 * This class extends the base AstNode class to provide comprehensive location information.
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves detailed location information for the AST node.
   * @param sourceFile - The path to the file containing the node
   * @param beginLine - The starting line number of the node
   * @param beginColumn - The starting column number of the node
   * @param endLine - The ending line number of the node
   * @param endColumn - The ending column number of the node
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Inherit location details from parent class
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, endLine, endColumn)
  }

  /**
   * Provides a string representation of the AST node.
   * @returns A string representation of the node
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships between AST nodes and comments using the AlertSuppression framework
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a 'noqa' suppression comment, which is a widely recognized mechanism
 * for disabling linter warnings in Python code. Both pylint and pyflakes respect
 * this convention, making it a standard for suppression in the Python ecosystem.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructs a NoqaSuppressionComment by identifying comments that match the noqa pattern.
   * The pattern is case-insensitive and allows for optional suffixes after the noqa keyword.
   */
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix (without colon)
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieves the annotation identifier for this suppression comment.
   * @returns The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression comment.
   * A noqa comment typically covers the entire line where it appears.
   * @param sourceFile - The path to the file containing the suppression
   * @param beginLine - The starting line number of the covered range
   * @param beginColumn - The starting column number of the covered range
   * @param endLine - The ending line number of the covered range
   * @param endColumn - The ending column number of the covered range
   */
  override predicate covers(
    string sourceFile, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Get comment location and verify it starts at column 1 (beginning of line)
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endColumn) and
    beginColumn = 1
  }
}