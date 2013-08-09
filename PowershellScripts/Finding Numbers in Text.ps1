#Regular Expressions are a great help in identifying and extracting data from text.
#Here's an example that finds and extracts a number that ends with a comma 

PS> $text = "I am looking for a number like this 67868683468932689223479, that is delimited by a comma."
PS> $pattern = '(\d*),' 
PS> if ($text -match $pattern) { $matches[1] } else { Write-Warning "Not found" }
67868683468932689223479
