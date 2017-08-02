# Convert DWARF type information as printed by 'readelf' into YAML format.
BEGIN { FS=": " }

/^ <1>/ { indent = "";   }    # top-level definition
/^ <2>/ { indent = "  "; }    # child definition

# From:
#   <0><b>: Abbrev Number: 1 (DW_TAG_compile_unit)
# To:
#   <b>:
#     tag: compile_unit
/Abbrev Number.*DW_TAG/ {
    match($1, /<[0-9a-f]+><([0-9a-f]+)>/, id);
    match($NF, "DW_TAG_([a-z_]+)", tag);
    printf("%s<0x%s>:\n", indent, id[1]);
    printf("%s  tag: %s\n", indent, tag[1]);
}

# From:
#   <47>   DW_AT_byte_size   : 24
# To:
#   byte_size: 24
/DW_AT_/ {
    gsub("\t", " ");            # tabs to spaces
    match($1, "DW_AT_([a-zA-Z0-9_]+)", name);
    printf("%s  %s: %s\n", indent, name[1], $NF);
}
