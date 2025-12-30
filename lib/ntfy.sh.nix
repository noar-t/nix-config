{ pkgs }:

{
  # Creates a ntfy.sh notification command using curl
  #
  # Example usage:
  #   mkNotification {
  #     title = "Backup Failed";
  #     priority = "urgent";
  #     tags = "warning,backup";
  #     message = "Backup failed with exit code 1";
  #     topicFile = "/home/noah/ntfy_topic";
  #   }
  #
  # Parameters:
  #   - title: Notification title
  #   - priority: Notification priority (default, min, low, high, urgent, max)
  #   - tags: Comma-separated tags
  #   - message: Notification message body
  #   - topicFile: Path to file containing the topic
  #
  # Returns: A shell command string that sends the notification
  mkNotification =
    {
      title,
      priority,
      tags,
      message,
      topicFile,
    }:
    ''
      ${pkgs.curl}/bin/curl \
        -H "Title: ${title}" \
        -H "Priority: ${priority}" \
        -H "Tags: ${tags}" \
        -d "${message}" \
        ntfy.sh/$(cat ${topicFile})
    '';
}
