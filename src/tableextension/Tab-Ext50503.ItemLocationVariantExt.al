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
        field(50504; "InventoryValue_0_6M"; Decimal) { } // New field for 0-6 months
        field(50505; "InventoryValue_6_12M"; Decimal) { } // New field for 6-12 months
        field(50506; "InventoryValue_12M"; Decimal) { }
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
