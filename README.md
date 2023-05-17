# PowerShell Script for Comparing Files

This PowerShell script is designed to compare files in two different directories and their subdirectories, identify duplicates, and copy them to new locations based on their similarity.

## Features

- Searches for duplicate files by name across all subdirectories
- Compares the hash values of duplicate files to determine if their contents are identical
- Copies identical files to a new location, preserving the relative path
- Copies non-identical files to a new location, appending "_Duplicate 1" and "_Duplicate 2" to the file names
- Generates output files with the results of the comparison
- Displays progress during the search for duplicates

## Usage

1. Define the directory locations at the beginning of the script:

```powershell
$dir1 = ""
$dir2 = ""
$destination = ""
$diffDestination = ""
```

2. Run the script in a PowerShell console.

## Output Files

- `FileLocations.txt`: Lists the full path of each pair of duplicate files found
- `FileComparisonResults.txt`: Stores the results of the comparison (identical or different) for each pair of duplicate files
- `IdenticalFiles.txt`: Lists the full path of identical files found
- `NonIdenticalFiles.txt`: Lists the full path of non-identical files found

## Limitations

- The script only finds files by name, not by content. Files with different names but identical content will not be detected as duplicates. As such, the later HASH check is only performed on a Name Basis

## Requirements

- PowerShell 3.0 or later

## License

This script is provided as-is under the MIT license. For more information, see the [LICENSE](./LICENSE) file.
