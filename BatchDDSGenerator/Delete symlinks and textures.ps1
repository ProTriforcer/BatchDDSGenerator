Import-Csv -Path ".\Texture database.csv" -Delimiter ";" -Encoding Unicode | ForEach-Object {Remove-Item ($_.Path.subString(0,$_.Path.length-3)+"dds") -Force}
Remove-Item ".\DDS Textures (DO NOT DELETE)\" -Recurse
Remove-Item ".\Texture database.csv"