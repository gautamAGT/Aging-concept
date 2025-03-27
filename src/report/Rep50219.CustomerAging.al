report 50219 "Customer Aging"
{
    DefaultLayout = RDLC;
    RDLCLayout = './CustomerReport1.rdl';
    Caption = 'Customer Aging Report';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            column(Customer_No_; "No.") { }
            column(Customer_Name; Name) { }
            column(Before; RemainingAmounts[1]) { }
            column(UserEnteredDate; AgingDates[1]) { }
            column(OneMonthLaterDate; AgingDates[2]) { }
            column(TwoMonthsLaterDate; AgingDates[3]) { }
            column(ThreeMonthsLaterDate; AgingDates[4]) { }
            column(RemainingAmountEnteredDate; RemainingAmounts[2]) { }
            column(RemainingAmountSecondGapLater; RemainingAmounts[3]) { }
            column(RemainingAmountThirdGap; RemainingAmounts[4]) { }
            column(TotalBalance; TotalBalance) { }
            column(firstUpperbound; firstUpperbound) { }
            column(secondUpperbound; secondUpperbound) { }
            column(thirdUpperbound; thirdUpperbound) { }

            trigger OnAfterGetRecord()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
            begin
                Clear(RemainingAmounts);
                Clear(TotalBalance);

                // Filter by the current customer
                CustLedgerEntry.SetRange("Customer No.", "No.");

                // Amounts before the SelectedDate
                //CustLedgerEntry.SetRange("Due Date");
                CustLedgerEntry.SetFilter("Due Date", '..%1', AgingDates[1] - 1);
                CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
                RemainingAmounts[1] := 0;
                if CustLedgerEntry.FindSet() then
                    repeat
                        RemainingAmounts[1] += CustLedgerEntry."Remaining Amount";
                    until CustLedgerEntry.Next() = 0;

                // Loop through each period (+1M, +2M, +3M)
                for i := 1 to 3 do begin
                    //CustLedgerEntry.SetRange("Due Date");
                    CustLedgerEntry.SetRange("Due Date", AgingDates[i], AgingDates[i + 1] - 1);
                    CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
                    RemainingAmounts[i + 1] := 0;
                    if CustLedgerEntry.FindSet() then
                        repeat
                            RemainingAmounts[i + 1] += CustLedgerEntry."Remaining Amount";
                        until CustLedgerEntry.Next() = 0;
                end;

                //Amounts after the last period
                CustLedgerEntry.SetRange("Due Date");
                CustLedgerEntry.SetFilter("Due Date", '%1..', AgingDates[4]);
                CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
                RemainingAmounts[4] := 0;
                if CustLedgerEntry.FindSet() then
                    repeat
                        RemainingAmounts[4] += CustLedgerEntry."Remaining Amount";
                    until CustLedgerEntry.Next() = 0;

                // Calculate total balance
                TotalBalance := RemainingAmounts[1] + RemainingAmounts[2] + RemainingAmounts[3] + RemainingAmounts[4];
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
                    Caption = 'Options';
                    field(SelectedDate; SelectedDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';

                    }
                    field(SelectedGap; SelectedGap)
                    {
                        ApplicationArea = All;
                        Caption = 'Month Gap (e.g., 1, 2, 3)';

                    }
                }
            }
        }

        // trigger OnOpenPage()
        // begin
        //     if SelectedDate = 0D then
        //         SelectedDate := WorkDate();
        // end;
    }

    trigger OnPreReport()
    begin
        if SelectedDate = 0D then
            SelectedDate := WorkDate();


        AgingDates[1] := SelectedDate;
        AgingDates[2] := CalcDate('+' + Format(SelectedGap) + 'M', SelectedDate);
        AgingDates[3] := CalcDate('+' + Format(SelectedGap * 2) + 'M', SelectedDate);
        AgingDates[4] := CalcDate('+' + Format(SelectedGap * 3) + 'M', SelectedDate);

        firstUpperbound := AgingDates[2] - 1;
        secondUpperbound := AgingDates[3] - 1;
        thirdUpperbound := AgingDates[4] - 1;

    end;

    var
        AgingDates: array[4] of Date;
        RemainingAmounts: array[4] of Decimal;
        SelectedDate: Date;
        SelectedGap: Integer;
        TotalBalance: Decimal;
        i: Integer;
        firstUpperbound: Date;
        secondUpperbound: Date;
        thirdUpperbound: Date;
}
