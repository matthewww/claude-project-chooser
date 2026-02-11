namespace ClaudeProjectChooser;

static class Program
{
    /// <summary>
    ///  The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main()
    {
        // Ensure only one instance is running
        using var mutex = new Mutex(true, "ClaudeProjectChooser_SingleInstance", out bool createdNew);
        
        if (!createdNew)
        {
            MessageBox.Show(
                "Claude Project Chooser is already running in the system tray.",
                "Already Running",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information
            );
            return;
        }

        // Configure application
        ApplicationConfiguration.Initialize();
        
        // Run the tray application
        Application.Run(new TrayApplicationContext());
    }    
}