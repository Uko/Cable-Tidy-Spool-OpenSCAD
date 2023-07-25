#!/bin/zsh

config_regex='^'
config_regex+='[[:space:]]*H[[:space:]]*=[[:space:]]*([0-9]+)'
config_regex+='[[:space:]]+W[[:space:]]*=[[:space:]]*([0-9]+)'
config_regex+='[[:space:]]+L[[:space:]]*=[[:space:]]*([0-9]+)'
config_regex+='[[:space:]]+C[[:space:]]*=[[:space:]]*([0-9]+)'
config_regex+='[[:space:]]+R[[:space:]]*=[[:space:]]*([0-9]+)'
config_regex+='[[:space:]]*$'

mkdir -p stl

for config in ${(f)"$(<config.txt)"};
do
  if [[ ! $config =~ $config_regex ]]
  then
    echo "Unexpected config line: $config" >&2
  else
    H=${match[1]}
    W=${match[2]}
    L=${match[3]}
    C=${match[4]}
    R=${match[5]}
    
    cable_dir_name="stl/Cables C$C"
    
    mkdir -p $cable_dir_name
    
    filename="H$(printf %03d $H)-W$(printf %03d $W)-L$(printf %03d $L)-C$(printf %02d $C)-R$R.stl"
    
    echo "Generating $filename"
    /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -q -DH=$H -DW=$W -DL=$L -DC=$C -DR=$R -o "$cable_dir_name/$filename" CableTidySpool.scad
  fi
done


