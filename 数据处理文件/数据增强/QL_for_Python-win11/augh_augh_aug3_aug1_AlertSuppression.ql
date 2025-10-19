/**
 * @name Alert suppression
 * @description Detects and evaluates alert suppression mechanisms in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as PythonComment

/**
 * Represents a single-line Python comment with location tracking capabilities.
 * Provides methods to retrieve location information and comment text.
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves location information for the comment.
   * @param sourceFile - Path to the source file containing the comment
   * @param beginLine - Starting line number of the comment
   * @param beginColumn - Starting column number of the comment
   * @param concludeLine - Ending line number of the comment
   * @param concludeColumn - Ending column number of the comment
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int concludeLine, int concludeColumn
  ) {
    // Delegate location retrieval to parent class implementation
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, concludeLine, concludeColumn)
  }

  /**
   * Retrieves the textual content of the comment.
   * @returns The raw text content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of the comment.
   * @returns String representation of the comment
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a Python AST node with location tracking capabilities.
 * Provides methods to retrieve location information for AST nodes.
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves location information for the AST node.
   * @param sourceFile - Path to the source file containing the node
   * @param beginLine - Starting line number of the node
   * @param beginColumn - Starting column number of the node
   * @param concludeLine - Ending line number of the node
   * @param concludeColumn - Ending column number of the node
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int concludeLine, int concludeColumn
  ) {
    // Delegate location retrieval to parent class implementation
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, concludeLine, concludeColumn)
  }

  /**
   * Provides a string representation of the AST node.
   * @returns String representation of the AST node
   */
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A suppression comment using the 'noqa' directive. This directive is recognized
 * by both pylint and pyflakes linters, and should be respected by LGTM alerts.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Initializes a NoqaSuppressionComment by identifying the noqa pattern.
   * Matches case-insensitive 'noqa' with optional suffix.
   */
  NoqaSuppressionComment() {
    // Identify comments containing the noqa directive
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieves the annotation identifier for this suppression.
   * @returns The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range affected by this suppression.
   * @param sourceFile - Path to the source file
   * @param beginLine - Starting line of the affected range
   * @param beginColumn - Starting column of the affected range
   * @param concludeLine - Ending line of the affected range
   * @param concludeColumn - Ending column of the affected range
   */
  override predicate covers(
    string sourceFile, int beginLine, int beginColumn, int concludeLine, int concludeColumn
  ) {
    // Extract comment location and verify it starts at column 1
    this.hasLocationInfo(sourceFile, beginLine, _, concludeLine, concludeColumn) and
    beginColumn = 1
  }
}