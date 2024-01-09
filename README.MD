# BatchDDSGenerator

This script is based on and does mostly the same thing as https://github.com/bbradson/DDSgenerator
But faster! How?
TLDR: it uses the magic of symlinks and wildcards to avoid launching thousands of processes, making the conversion process take about half as long on my machine.


Starting processes isn't free, and the original script does that 3 times for every file it converts. 
This script avoids doing that by sending as many textures to one process as possible. Since you can't just send 15k lines of text as an argument, this is where it gets creative.

First, it builds a list of textures and their hashes and saves it as a .csv file. Then it creates a symbolic link for each unique texture in a temporary folder. Symbolic links are like shortcuts, but most programs see them as the original files.
Now that all the "textures" are in the same folder, they can be sorted by opacity and format with only one execution of magick.exe and two executions of texdiag.exe by specifying a wildcard as the source path.

They are then converted to different DDS formats like in the original script, except imagemagick can only convert one file at a time, so instead texconv is launched once for each sorting folder (4 in total). Except it still can't properly convert to BC1_UNORM_SRGB, so opaque SRGB textures are converted to BC7_UNORM_SRGB instead. They will take a bit more space and memory(?), but you don't make DDS textures to save space.

Now, you can't just move the DDS textures back to the mod folders, since only one file was generated for each unique texture, and powershell scripts aren't very nice for implementing fancy logic. Copying them all is slow (but you have the option, read usage). That's where symlinks come to the rescue again. The script creates symlinks where the DDS textures are supposed to be and makes them point to the files in the "DDS Textures (DO NOT DELETE)" folder. Yes, you should keep that folder.

After all that, all unnecessary files and folders are automatically deleted.


## USAGE
 - Place the BatchDDSGenerator folder into a folder that contains png or jpg pictures anywhere, including subfolders, and all their subfolders.
 - Pick and right-click a .ps1 file.
 - Run with powershell. You may need admin privileges
 - Wait for the powershell window to close.

Run "BatchDDSGeneratorSymlink.ps1" to save time and SSD life by not copying the textures.

OR

Run "BatchDDSGeneratorCopy.ps1" to save some potential symlink related headache.


Run "Delete symlinks and textures.ps1" if you want to delete generated textures and symlinks pointing to them. This will not work without the "Texture database.csv" file!
