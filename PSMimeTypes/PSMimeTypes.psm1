<#
  .SYNOPSIS
      PSMimeTypes - A PowerShell module for resolving MIME types.

  .DESCRIPTION
      PSMimeTypes provides functions to determine the MIME type of files based on their
      extensions or filenames. It utilizes the JSHTTP Mime-DB for lookups and supports
      importing a local database for offline use.

  .EXPORTS
      - Convert-ExtensionToMimeType
      - Convert-FileNameToMimeType
      - Import-MimeDBFromFile

  .FUNCTIONS
      - Convert-ExtensionToMimeType
          Resolves a MIME type based on a given file extension.

          PARAMETERS:
              - Extension (String, Mandatory): The file extension (e.g., "jpg", "pdf").

      - Convert-FileNameToMimeType
          Extracts the file extension from a filename and resolves its MIME type.

          PARAMETERS:
              - FileName (String, Mandatory): The full filename including the extension.

      - Import-MimeDBFromFile
          Imports a local JSON-based MIME database for offline lookups.

          PARAMETERS:
              - Path (String, Mandatory): The path to the JSON MIME database file.

  .EXAMPLES
      Resolving MIME type from an extension:
          Convert-ExtensionToMimeType -Extension "png"
          # Output: image/png

      Resolving MIME type from a filename:
          Convert-FileNameToMimeType -FileName "example.docx"
          # Output: application/vnd.openxmlformats-officedocument.wordprocessingml.document

      Importing a local MIME database:
          Import-MimeDBFromFile -Path "C:\mime-db.json"
          # Output: True (if successful) or False (if failed)

  .LINK
      Github: https://github.com/t3hn3rd/PSMimeTypes
      JSHTTP Mime-DB: https://github.com/jshttp/mime-db
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

  .INPUTS
    [String] $Extension
      The file extension to look up.

  .OUTPUTS
    [String]
      The corresponding MIME type for the given file extension.

  .EXAMPLE
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
  process {
    return [MimeTypeResolver]::resolveMimeType($Extension)
  }
}

<#
  .SYNOPSIS
    Determines the MIME type of a file based on its extension.

  .DESCRIPTION
    The Convert-FileNameToMimeType function extracts the file extension from a given
    filename and returns the corresponding MIME type using Convert-ExtensionToMimeType.

  .INPUTS
    [String] $FileName
      The name of the file, including its extension.

  .OUTPUTS
    [String]
      The corresponding MIME type for the file's extension.

  .EXAMPLE
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
  process {
    $Extension = [System.IO.Path]::GetExtension($FileName)
    return Convert-ExtensionToMimeType -Extension $Extension
  }
}

<#
  .SYNOPSIS
    Imports a MIME type database from a JSON file.

  .DESCRIPTION
    The Import-MimeDBFromFile function loads a MIME type database from the specified
    file and updates the MimeTypeResolver class with the imported data.

  .INPUTS
    [String] $Path
      The file path to the MIME type database in JSON format.

  .OUTPUTS
    [Bool]
      Returns $true if the import was successful, otherwise $false.

  .EXAMPLE
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
  process {
    return [MimeTypeResolver]::ImportMimeDBFromFile($Path)
  }
}

Export-ModuleMember -Function Convert-ExtensionToMimeType, Convert-FileNameToMimeType, Import-MimeDBFromFile