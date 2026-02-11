namespace ClaudeProjectChooser;

/// <summary>
/// Represents a Claude project with its metadata
/// </summary>
public class ClaudeProject
{
    public string SessionName { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string FullPath { get; set; } = string.Empty;
    public DateTime Modified { get; set; }
    public string RelativeTime { get; set; } = string.Empty;

    public override string ToString() => $"{DisplayName} ({RelativeTime})";
}
