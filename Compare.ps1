## Defining the Directory Locations
$dir1 = ""
$dir2 = ""
$destination = ""
$diffDestination = ""

## Print the Directories for confirmation purposes
$dir1
$dir2

## Split the names of the directories for printing purposes - excludes unnecessarily long directory paths
$dir1LastSection = Split-Path -Path $dir1 -Leaf
$dir2LastSection = Split-Path -Path $dir2 -Leaf

## Searches through directories and subdirectories to find all files
$filesInDir1 = Get-ChildItem -Path $dir1 -File -Recurse | Select-Object -ExpandProperty FullName
$filesInDir2 = Get-ChildItem -Path $dir2 -File -Recurse | Select-Object -ExpandProperty FullName

Write-Output "`n`nChecking for file duplicates between '$dir1LastSection' and '$dir2LastSection'`n"

## Checking for duplicate files by Name across all subdirectories of $dir1 and $dir2
## Writing names of duplicate files to the FilesLocation.txt document
$currentIndex = 0
$totalFiles = $filesInDir1.Count

foreach ($file in $filesInDir1) {
    $fileName = (Get-Item $file).Name
    $matchingFiles = $filesInDir2 | Where-Object { (Get-Item $_).Name -eq $fileName }

    foreach ($matchingFile in $matchingFiles) {
        Write-Host "Found duplicate files: $fileName"
        $file, $matchingFile | Out-File -Append -FilePath "FileLocations.txt"
    }

    $currentIndex++
    $progress = ($currentIndex / $totalFiles) * 100
    Write-Progress -Activity "Searching for duplicates" -Status "Progress: $($progress.ToString('0.00'))%" -PercentComplete $progress
}

Write-Output "`nComparing file hash values:`n"

## Checking the HASH Values using SHA256 of each duplicate file found, to check whether contents of files are duplicates, using the FilesLocation.txt file for the files to check
## Iterates through each set of lines (1&2, 3&4) to check for duplicates
$fileLocations = Get-Content "FileLocations.txt"
$outputFile = "FileComparisonResults.txt"
$identicalFiles = "IdenticalFiles.txt"
$nonIdenticalFiles = "NonIdenticalFiles.txt"

for ($i = 0; $i -lt $fileLocations.Count; $i += 2) {
    $file1Hash = Get-FileHash -Path $fileLocations[$i] -Algorithm SHA256
    $file2Hash = Get-FileHash -Path $fileLocations[$i + 1] -Algorithm SHA256

    $file1Name = (Get-Item $fileLocations[$i]).Name
    $file2Name = (Get-Item $fileLocations[$i + 1]).Name

    ## Determine if files are identical or different based on their hash values
    if ($file1Hash.Hash -eq $file2Hash.Hash) {
        $result = "Files $file1Name and $file2Name are identical."
        $fileLocations[$i], $fileLocations[$i + 1] | Out-File -Append -FilePath $identicalFiles
        
        ## Copy identical files to the new location, preserving the relative path
        $relativePath = (Get-Item $fileLocations[$i]).FullName.Substring($dir1.Length)
        $newPath = Join-Path -Path $destination -ChildPath $relativePath
        $newDir = Split-Path -Path $newPath -Parent
        if (-not (Test-Path $newDir)) {
            New-Item -ItemType Directory -Path $newDir | Out-Null
        }
        Copy-Item -Path $fileLocations[$i] -Destination $newPath
    } else {
        $result = "Files $file1Name and $file2Name are different."
        $fileLocations[$i], $fileLocations[$i + 1] | Out-File -Append -FilePath $nonIdenticalFiles

        ## Copy different files to the new location, preserving the relative path and appending "_Duplicate 1" and "_Duplicate 2" to the file names
        $file1RelativePath = (Get-Item $fileLocations[$i]).FullName.Substring($dir1.Length)
        $file2RelativePath = (Get-Item $fileLocations[$i + 1]).FullName.Substring($dir2.Length)

        $file1NewPath = Join-Path -Path $diffDestination -ChildPath ($file1RelativePath -replace '\.[^.]*$', '_Duplicate 1$&')
        $file2NewPath = Join-Path -Path $diffDestination -ChildPath ($file2RelativePath -replace '\.[^.]*$', '_Duplicate 2$&')

        $file1NewDir = Split-Path -Path $file1NewPath -Parent
        $file2NewDir = Split-Path -Path $file2NewPath -Parent

        ## Create new directories if they do not exist
        if (-not (Test-Path $file1NewDir)) {
            New-Item -ItemType Directory -Path $file1NewDir | Out-Null
        }
        if (-not (Test-Path $file2NewDir)) {
            New-Item -ItemType Directory -Path $file2NewDir | Out-Null
        }

        ## Copy the different files to their respective new locations
        Copy-Item -Path $fileLocations[$i] -Destination $file1NewPath
        Copy-Item -Path $fileLocations[$i + 1] -Destination $file2NewPath
    }
    ## Write the result (identical or different) to the console and save it in the output file
    Write-Host $result
    $result | Out-File -Append -FilePath $outputFile
}
