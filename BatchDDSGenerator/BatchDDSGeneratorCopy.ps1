"Building a list of textures..."
Get-ChildItem ..\ -Include "*.jpg", "*.png" -Recurse | ForEach-Object {Get-FileHash $_.FullName -Algorithm SHA256 | Select-Object Hash, Path} | Export-Csv -Path ".\Texture database.csv" -NoTypeInformation -Delimiter ";" -Encoding Unicode
New-Item -Path .\ -Name bddsgtmp -ItemType "directory" -Force

"Creating symbolic links..."
Import-Csv -Path ".\Texture database.csv" -Delimiter ";" -Encoding Unicode | ForEach-Object {New-Item -ItemType SymbolicLink -Path (".\bddsgtmp\" + $_.Hash + "slink") -Target $_.Path -Force}
New-Item -Path .\bddsgtmp\ -Name Opaque -ItemType "directory" -Force
New-Item -Path .\bddsgtmp\ -Name Transparent -ItemType "directory" -Force
New-Item -Path .\bddsgtmp\Opaque\ -Name BC1_UNORM -ItemType "directory" -Force
New-Item -Path .\bddsgtmp\Opaque\ -Name BC1_UNORM_SRGB -ItemType "directory" -Force
New-Item -Path .\bddsgtmp\Transparent\ -Name BC7_UNORM -ItemType "directory" -Force
New-Item -Path .\bddsgtmp\Transparent\ -Name BC7_UNORM_SRGB -ItemType "directory" -Force

"Sorting textures..."
.\magick.exe identify -format "%d %f %[opaque]\n" .\bddsgtmp\* | ForEach-Object {Move-Item -Path ($_.split(" ")[0]+"\"+$_.split(" ")[1]) -Destination ($_.split(" ")[0]+@({\Transparent\},{\Opaque\})[$_.split(" ")[2] -eq "True"]+$_.split(" ")[1]) -ErrorAction SilentlyContinue}
.\texdiag.exe info .\bddsgtmp\Opaque\* | Select-String -Pattern 'slink' -Context 0,6 | foreach {If ($_.context.PostContext[5].substring(16).Contains("SRGB")){$format="BC1_UNORM_SRGB"} else {$format="BC1_UNORM"};Move-Item -Path ($_.line) -Destination ($_.line.remove(18)+$format+$_.line.substring(17))}
.\texdiag.exe info .\bddsgtmp\Transparent\* | Select-String -Pattern 'slink' -Context 0,6 | foreach {If ($_.context.PostContext[5].substring(16).Contains("SRGB")){$format="BC7_UNORM_SRGB"} else {$format="BC7_UNORM"};Move-Item -Path ($_.line) -Destination ($_.line.remove(23)+$format+$_.line.substring(22))}
New-Item -Path .\ -Name "DDS Textures (DO NOT DELETE)" -ItemType "directory" -Force

"Converting textures..."
.\texconv.exe -f BC1_UNORM -y -vflip -fixbc4x4 .\bddsgtmp\Opaque\BC1_UNORM\* -o "DDS Textures (DO NOT DELETE)"
#.\texconv.exe -f BC1_UNORM_SRGB -y -vflip -fixbc4x4 .\bddsgtmp\Opaque\BC1_UNORM_SRGB\* -o "DDS Textures (DO NOT DELETE)"
# Wow, it's been three years and it's still shit and can't properly convert to BC1_UNORM_SRGB
.\texconv.exe -f BC7_UNORM_SRGB -y -vflip -fixbc4x4 .\bddsgtmp\Opaque\BC1_UNORM_SRGB\* -o "DDS Textures (DO NOT DELETE)" #Screw it, BC7 it is
.\texconv.exe -f BC7_UNORM -y -vflip -fixbc4x4 .\bddsgtmp\Transparent\BC7_UNORM\* -o "DDS Textures (DO NOT DELETE)"
.\texconv.exe -f BC7_UNORM_SRGB -y -vflip -fixbc4x4 .\bddsgtmp\Transparent\BC7_UNORM_SRGB\* -o "DDS Textures (DO NOT DELETE)"

"Plugging DDS textures back in"
#Create symlinks to avoid copying the textures
#Import-Csv -Path ".\Texture database.csv" -Delimiter ";" -Encoding Unicode | ForEach-Object {New-Item -ItemType SymbolicLink -Path ($_.Path.subString(0,$_.Path.length-3)+"dds") -Target (".\DDS Textures (DO NOT DELETE)\" + $_.Hash + "slink.dds") -Force}

#OR

#Copy the textures to avoid having to deal with symlinks
Import-Csv -Path ".\Texture database.csv" -Delimiter ";" -Encoding Unicode | ForEach-Object {Copy-Item (".\DDS Textures (DO NOT DELETE)\" + $_.Hash + "slink.dds") -Destination ($_.Path.subString(0,$_.Path.length-3)+"dds") -Force -ErrorAction SilentlyContinue}
Remove-Item ".\DDS Textures (DO NOT DELETE)\" -Recurse


#delete symlinks/copied textures
#Import-Csv -Path ".\Texture database.csv" -Delimiter ";" -Encoding Unicode | ForEach-Object {Remove-Item ($_.Path.subString(0,$_.Path.length-3)+"dds") -Force}


#You probably should keep it
#Remove-Item ".\Texture database.csv"

"Cleaning up"
Remove-Item .\bddsgtmp\ -Recurse
