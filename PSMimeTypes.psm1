<#
	.SYNOPSIS
		A utility module to resolve MIME Types from Filenames/Extensions.
	.DESCRIPTION
		This module allows for the resolution of MIME types from a provided Filename/Extension.
    
    It caches & utilizes the JSHTTP Mime-DB to resolve the MIME type based on the provided extension,
    this means that by default it requires an internet connection to work, however, you can optionally
    configure the module to use a local copy of the Mime-DB.
	.NOTES
        FILE NAME: 
            PSMimeTypes.psm1
        AUTHOR: 
            Kieron Morris (kjm@kieronmorris.me)
        VERSION:
            1.0.0
        GUID:
            5d95d259-3cb3-4e5a-b65f-13b3e6ac1c85
        COPYRIGHT:
            (c) 2025 t3hn3rd (kjm@kieronmorris.me). All rights reserved.
#>

<# 
  .SYNOPSIS 
    A PowerShell class for resolving MIME types from file extensions.
  .DESCRIPTION
    The MimeTypeResolver class provides a method to determine the MIME type of a given file extension by 
    referencing an online MIME database or an imported JSON file.

  .PROPERTIES 
    - MimeTypes [PSObject]: Stores the MIME type database.

  .METHODS 
    - resolveMimeType($Extension): Returns the MIME type for a given file extension. 
    - ImportMimeDBFromFile($Path): Loads a MIME type database from a local JSON file.
#>
class MimeTypeResolver {
  hidden static [PSObject] $MimeTypes
  static [string] resolveMimeType([string]$Extension) {
    if(-not([MimeTypeResolver]::MimeTypes)) {
      [MimeTypeResolver]::MimeTypes = Invoke-RestMethod -Uri "https://cdn.jsdelivr.net/gh/jshttp/mime-db@master/db.json"
    }
    $Extension = $Extension.TrimStart(".")
    $AllProperties = [MimeTypeResolver]::MimeTypes.PSObject.Properties
    $MimeType = $AllProperties | Where-Object { $_.Value.extensions -contains $Extension }
    if($MimeType.name) {
      return $MimeType.name
    }
    return "application/octet-stream"
  }
  static [bool] ImportMimeDBFromFile([string]$Path) {
    try {
      $Import = $(Get-Content -Path $Path | ConvertFrom-Json)
      [MimeTypeResolver]::MimeTypes = $Import
      return $true
    } catch {
      return $false
    }
  }
}

<#
.SYNOPSIS
    Converts a file extension to its corresponding MIME type.

.DESCRIPTION
    The Convert-ExtensionToMimeType function takes a file extension as input and 
    returns the associated MIME type using the MimeTypeResolver class.

.PARAMETERS
    [String] $Extension
        The file extension to look up.

.OUTPUTS
    [String]
        The corresponding MIME type for the given file extension.

.EXAMPLES
    Convert a .jpg extension to its MIME type:
    
    PS> Convert-ExtensionToMimeType -Extension "jpg"
    image/jpeg

    Convert a .txt extension to its MIME type:

    PS> Convert-ExtensionToMimeType -Extension "txt"
    text/plain
#>
function Convert-ExtensionToMimeType {
  param (
    [Parameter(Mandatory=$true,
              Position = 0,
              ValueFromPipeline = $true,
              ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Extension
  )
  return [MimeTypeResolver]::resolveMimeType($Extension)
}

<#
.SYNOPSIS
    Determines the MIME type of a file based on its extension.

.DESCRIPTION
    The Convert-FileNameToMimeType function extracts the file extension from a given 
    filename and returns the corresponding MIME type using Convert-ExtensionToMimeType.

.PARAMETERS
    [String] $FileName
        The name of the file, including its extension.

.OUTPUTS
    [String]
        The corresponding MIME type for the file's extension.

.EXAMPLES
    Get the MIME type of an image file:
    
    PS> Convert-FileNameToMimeType -FileName "picture.jpg"
    image/jpeg

    Get the MIME type of a text file:

    PS> Convert-FileNameToMimeType -FileName "document.txt"
    text/plain
#>
function Convert-FileNameToMimeType {
  param (
    [Parameter(Mandatory=$true,
              Position = 0,
              ValueFromPipeline = $true,
              ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FileName
  )
  $Extension = [System.IO.Path]::GetExtension($FileName)
  return Convert-ExtensionToMimeType -Extension $Extension
}

<#
.SYNOPSIS
    Imports a MIME type database from a JSON file.

.DESCRIPTION
    The Import-MimeDBFromFile function loads a MIME type database from the specified 
    file and updates the MimeTypeResolver class with the imported data.

.PARAMETERS
    [String] $Path
        The file path to the MIME type database in JSON format.

.OUTPUTS
    [Bool]
        Returns $true if the import was successful, otherwise $false.

.EXAMPLES
    Import a MIME database from a local file:
    
    PS> Import-MimeDBFromFile -Path "C:\path\to\mime-db.json"
    True

    Attempt to import a non-existent file:

    PS> Import-MimeDBFromFile -Path "C:\invalid\path.json"
    False
#>
function Import-MimeDBFromFile {
  param (
    [Parameter(Mandatory=$true,
              Position = 0,
              ValueFromPipeline = $true,
              ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  return [MimeTypeResolver]::ImportMimeDBFromFile($Path)
}

Export-ModuleMember -Function Convert-ExtensionToMimeType, Convert-FileNameToMimeType, Import-MimeDBFromFile