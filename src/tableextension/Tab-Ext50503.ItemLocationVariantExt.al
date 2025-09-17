tableextension 50503 ItemLocationVariantExt extends "Item Location Variant Buffer"
{
    fields
    {
        field(50501; Quantity0_6M; Decimal)
        {
            Caption = 'Quantity (0-6M)';
        }

        field(50502; Quantity6_12M; Decimal)
        {
            Caption = 'Quantity (6-12M)';
        }

        field(50503; QuantityOlderThan12M; Decimal)
        {
            Caption = 'Quantity (Older Than 12M)';
        }
    }

    keys
    {
        // No changes to keys for now
    }

    fieldgroups
    {
        // No changes to field groups for now
    }
}
