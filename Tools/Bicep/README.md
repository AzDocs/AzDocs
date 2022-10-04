# Bicep documentation generation tool

The tool is split into two files. The `Get-BicepMetadata.ps1` creates `pscustomobject` with the metadata of the bicep files. 
The `Update-MetadataMarkdown.ps1` creates the markdown files based on the metadata.

For getting a example how getting markdown files from the bicep files, see the examples in the `Update-MetadataMarkdown`:

```
. .\Update-MetadataMarkdown.ps1               # load the function 
 get-help Update-MetadataMarkdown -Examples   # Fetching the examples from the readme
```