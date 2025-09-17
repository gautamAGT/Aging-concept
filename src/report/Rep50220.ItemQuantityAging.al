report 50220 "Item Quantity Aging"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ItemQuantityAging.rdl';
    Caption = 'Item Quantity Aging';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            column(Item_No; "No.") { }
            column(Description; Description) { }


            column(Quantity_0_6M; Quantities[1]) { }
            column(Quantity_6_12M; Quantities[2]) { }
            column(Quantity_OlderThan_12M; Quantities[3]) { }


            column(DateRange_0_6M; Format(Labels[1])) { }
            column(DateRange_6_12M; Format(Labels[2])) { }
            column(DateRange_Older_Than_12M; Format(Labels[3])) { }
            column(SelectedDate; SelectedDate) { }

            column(label1; label1) { }
            column(label2; label2) { }
            column(label3; label3) { }

            trigger OnAfterGetRecord()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
                FromDate: Date;
                ToDate: Date;
            begin
                Clear(Quantities);
                ItemLedgerEntry.SetRange("Item No.", "No.");


                for i := 1 to 3 do begin

                    ItemLedgerEntry.SetRange("Posting Date");
                    case i of
                        1:
                            begin // 0–6 months
                                FromDate := AgingDates[2] + 1;
                                ToDate := AgingDates[1];
                                ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', FromDate, ToDate);
                            end;

                        2:
                            begin // 6–12 months
                                FromDate := AgingDates[3] + 1;
                                ToDate := AgingDates[2];
                                ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', FromDate, ToDate);
                            end;

                        3:
                            begin // older than 12 months
                                ToDate := AgingDates[3];
                                ItemLedgerEntry.SetFilter("Posting Date", '..%1', ToDate);
                            end;
                    end;

                    if ItemLedgerEntry.FindSet() then
                        repeat
                            Quantities[i] += ItemLedgerEntry.Quantity;
                        until ItemLedgerEntry.Next() = 0;
                end;

            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(SelectedDate; SelectedDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Reference Date';
                        ToolTip = 'Used as the reference point for aging calculation.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if SelectedDate = 0D then
            SelectedDate := WorkDate();


        AgingDates[1] := SelectedDate;
        AgingDates[2] := CalcDate('-6M', SelectedDate);
        AgingDates[3] := CalcDate('-12M', SelectedDate);


        Labels[1] := Format(AgingDates[2] + 1, 0, '<Day,2>-<Month,2>-<Year4>') + ' to ' +
                     Format(AgingDates[1], 0, '<Day,2>-<Month,2>-<Year4>');


        Labels[2] := Format(AgingDates[3] + 1, 0, '<Day,2>-<Month,2>-<Year4>') + ' to ' +
                     Format(AgingDates[2], 0, '<Day,2>-<Month,2>-<Year4>');

        Labels[3] := 'Before ' + Format(AgingDates[3] + 1 - 1, 0, '<Day,2>-<Month,2>-<Year4>');

        //     Message(
        //    'Aging Date Ranges:\n' +
        //    '0-6 Months: %1\n' +
        //    '6-12 Months: %2\n' +
        //    'Older than 12 Months: %3',
        //    Labels[1], Labels[2], Labels[3]);

        label1 := Labels[1];
        label2 := Labels[2];
        label3 := Labels[3];
    end;

    var
        SelectedDate: Date;
        AgingDates: array[3] of Date;  // [1] = Today, [2] = -6M, [3] = -12M
        Labels: array[3] of Text;
        Quantities: array[3] of Decimal;
        i: Integer;
        label1: text;
        label2: text;
        label3: text;

}
