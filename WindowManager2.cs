using Godot;
using System;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

public partial class WindowManager2 : Node 
{
    public Godot.Collections.Array<Rect2> windowPositions = new();

    public Godot.Collections.Dictionary foregroundWindowData = new();
    
    // Import the EnumWindows and GetWindowRect functions from user32.dll
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool IsIconic(IntPtr hWnd); // Check if window is minimized

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);


    [DllImport("user32.dll")]
    private static extern int GetWindowTextLength(IntPtr hWnd);

    // Define the RECT structure to represent a rectangle
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    // Define the delegate type for the EnumWindows callback function
    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    public override void _Ready()
    {
        // Call EnumWindows with a callback function to enumerate all top-level windows
        List<WindowInfo> windows = new();
        EnumWindows(EnumWindowsCallback, GCHandle.ToIntPtr(GCHandle.Alloc(windows)));
        
        // Print information about each enumerated window
        foreach (WindowInfo window in windows)
        {
            windowPositions.Add(new Rect2(new Vector2(window.Rect.Left,  window.Rect.Top), new Vector2(window.Rect.Right,  window.Rect.Bottom)));
        }
    }

    public override void _Process(double delta)
    {
        IntPtr hWnd = GetForegroundWindow();

        int length = GetWindowTextLength(hWnd);

        // Get the window title
        System.Text.StringBuilder title = new System.Text.StringBuilder(length + 1);
        GetWindowText(hWnd, title, title.Capacity);

        GetWindowRect(hWnd, out RECT rect);
        Rect2 windowRect = new()
        {
            Position = new Vector2(rect.Left, rect.Top),
            End = new Vector2(rect.Right, rect.Bottom)
        };

        foregroundWindowData["rect"] = windowRect;
        foregroundWindowData["name"] = title.ToString();
        foregroundWindowData["hWnd"] = hWnd.ToInt32();


        // Called every frame.
        base._Process(delta);
    }

    public Godot.Rect2 get_data(){
        IntPtr hWnd = GetForegroundWindow();
        GetWindowRect(hWnd, out RECT rect);
        Rect2 windowRect = new()
        {
            Position = new Vector2(rect.Left, rect.Top),
            End = new Vector2(rect.Right, rect.Bottom)
        };


        return windowRect;
    }
        



    // Callback function for EnumWindows
    private static bool EnumWindowsCallback(IntPtr hWnd, IntPtr lParam)
    {
        // Check if the window is visible and not minimized
        if (!IsWindowVisible(hWnd) || IsIconic(hWnd))
            return true;

        // Get the length of the window title
        int length = GetWindowTextLength(hWnd);
        if (length == 0)
            return true;

        // Get the window title
        System.Text.StringBuilder title = new System.Text.StringBuilder(length + 1);
        GetWindowText(hWnd, title, title.Capacity);

        // Check if the window title indicates a system window (modify as needed)
        // if (title.ToString().Contains("Program Manager") || title.ToString().Contains("Task Switching") || title.ToString().Contains("Shell_TrayWnd") ||
        // title.ToString().Contains("Windows"))
        //  return true;

        // Get the dimensions of the window
        GetWindowRect(hWnd, out RECT rect);

        // Add information about the enumerated window to the list
        List<WindowInfo> windows = (List<WindowInfo>)GCHandle.FromIntPtr(lParam).Target;
        windows.Add(new WindowInfo(hWnd, rect, title.ToString()));

        // Continue enumeration
        return true;
    }

    // Structure to store window information
    private struct WindowInfo
    {
        public IntPtr Handle;
        public RECT Rect;

        public String Title;

        public WindowInfo(IntPtr handle, RECT rect, String title)
        {
            Handle = handle;
            Rect = rect;
            Title = title;
        }
    }
}