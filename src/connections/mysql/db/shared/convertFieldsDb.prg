function convertFieldsDb(oRow)
    local value, i, cKey, hRow := { => }

    for i := 1 to hmg_len(oRow:aRow)
        cKey := oRow:FieldName(i)
        value := oRow:FieldGet(i)
        if ValType(value) == "C"
            value := ansi_to_unicode(value)
        elseif ValType(value) == "N"
            value := hb_ntos(value)
        endif
        hb_hSet(hRow, cKey, value)
    next

return hRow
