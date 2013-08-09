$files = ls c:\whereeverhtefilescam3from =incl *.xls

foreach ($file in $files) {

   $fid = $file.split("_")[2].split("-")[1].substring(1)
}
   $nfn = "drive:\folder\" + "filename_x_" + $Fid + ".xls"

   copy $file.fullname $nfn

}