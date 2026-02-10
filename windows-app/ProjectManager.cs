using Newtonsoft.Json;

namespace ClaudeProjectChooser;

/// <summary>
/// Manages discovery and caching of Claude projects
/// </summary>
public class ProjectManager
{
    private readonly string _projectsDir;
    private readonly string _cacheFile;
    private readonly TimeSpan _cacheMaxAge;

    public ProjectManager()
    {
        _projectsDir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
            ".claude", "projects"
        );

        _cacheFile = Path.Combine(
            Path.GetTempPath(),
            ".claude-projects-cache.json"
        );

        _cacheMaxAge = TimeSpan.FromMinutes(5);
    }

    /// <summary>
    /// Gets the list of Claude projects, using cache if available and not expired
    /// </summary>
    public List<ClaudeProject> GetProjects(bool forceRefresh = false)
    {
        // Try to load from cache first
        if (!forceRefresh && TryLoadFromCache(out var cachedProjects))
        {
            return cachedProjects;
        }

        // Build fresh project list
        var projects = DiscoverProjects();

        // Save to cache
        SaveToCache(projects);

        return projects;
    }

    private bool TryLoadFromCache(out List<ClaudeProject> projects)
    {
        projects = new List<ClaudeProject>();

        if (!File.Exists(_cacheFile))
            return false;

        try
        {
            var fileInfo = new FileInfo(_cacheFile);
            var age = DateTime.Now - fileInfo.LastWriteTime;

            if (age > _cacheMaxAge)
                return false;

            var json = File.ReadAllText(_cacheFile);
            var cached = JsonConvert.DeserializeObject<List<ClaudeProject>>(json);

            if (cached != null && cached.Count > 0)
            {
                projects = cached;
                // Update relative times
                foreach (var project in projects)
                {
                    project.RelativeTime = FormatRelativeTime(project.Modified);
                }
                return true;
            }
        }
        catch
        {
            // Cache file corrupted or unreadable
        }

        return false;
    }

    private void SaveToCache(List<ClaudeProject> projects)
    {
        try
        {
            var json = JsonConvert.SerializeObject(projects, Formatting.Indented);
            File.WriteAllText(_cacheFile, json);
        }
        catch
        {
            // Ignore cache write failures
        }
    }

    private List<ClaudeProject> DiscoverProjects()
    {
        var projects = new List<ClaudeProject>();

        if (!Directory.Exists(_projectsDir))
            return projects;

        var sessionDirs = Directory.GetDirectories(_projectsDir)
            .Select(d => new DirectoryInfo(d))
            .OrderBy(d => d.LastWriteTime) // Oldest first, so newest will be at end
            .ToList();

        foreach (var dir in sessionDirs)
        {
            try
            {
                var actualPath = GetActualProjectPath(dir.FullName);

                if (!string.IsNullOrWhiteSpace(actualPath))
                {
                    projects.Add(new ClaudeProject
                    {
                        SessionName = dir.Name,
                        DisplayName = actualPath,
                        FullPath = actualPath,
                        Modified = dir.LastWriteTime,
                        RelativeTime = FormatRelativeTime(dir.LastWriteTime)
                    });
                }
            }
            catch
            {
                // Skip projects that can't be read
            }
        }

        return projects;
    }

    private string? GetActualProjectPath(string sessionFolder)
    {
        try
        {
            var jsonlFiles = Directory.GetFiles(sessionFolder, "*.jsonl");

            if (jsonlFiles.Length == 0)
                return null;

            // Read the first JSONL file
            var lines = File.ReadAllLines(jsonlFiles[0]);

            foreach (var line in lines)
            {
                try
                {
                    dynamic? obj = JsonConvert.DeserializeObject(line);
                    if (obj?.cwd != null)
                    {
                        return obj.cwd.ToString();
                    }
                }
                catch
                {
                    // Skip invalid JSON lines
                }
            }
        }
        catch
        {
            // Error reading session folder
        }

        return null;
    }

    private string FormatRelativeTime(DateTime date)
    {
        var now = DateTime.Now;
        var diff = now - date;

        if (diff.TotalMinutes < 1)
            return "just now";
        if (diff.TotalMinutes < 60)
            return $"{Math.Round(diff.TotalMinutes)}m ago";
        if (diff.TotalHours < 24)
            return $"{Math.Round(diff.TotalHours)}h ago";
        if (diff.TotalDays < 7)
            return $"{Math.Round(diff.TotalDays)}d ago";

        return date.ToString("MMM d, h:mm tt");
    }

    /// <summary>
    /// Clears the project cache
    /// </summary>
    public void ClearCache()
    {
        try
        {
            if (File.Exists(_cacheFile))
            {
                File.Delete(_cacheFile);
            }
        }
        catch
        {
            // Ignore cache deletion failures
        }
    }
}
