codeunit 50100 "Customer Category Mgt_PKT"
{
    procedure CreateDefaultCategory()
    var
        CustomerCategory: Record "Customer Category_PKT";
    begin
        CustomerCategory.No := 'DEFAULT';
        CustomerCategory.Description := 'Default Customer Category';
        CustomerCategory.Default := true;
        if CustomerCategory.Insert then;
    end;


    procedure AssignDefaultCategory(CustomerCode: Code[20])

    var
        Customer: Record Customer;
        CustomerCategory: Record "Customer Category_PKT";
    begin
        //Set default category for a Customer        
        Customer.Get(CustomerCode);
        CustomerCategory.SetRange(Default, true);
        if CustomerCategory.FindFirst() then begin
            Customer."Customer Category_PKT" := CustomerCategory.No;
            Customer.Modify();
        end;
    end;

    procedure AssignDefaultCategory()
    var
        Customer: Record Customer;
        CustomerCategory: Record "Customer Category_PKT";
    begin
        //Set default category for ALL Customer       
        CustomerCategory.SetRange(Default, true);
        if CustomerCategory.FindFirst() then begin
            Customer.SetFilter("Customer Category_PKT", '<>%1', '');
            if Customer.FindSet(true) then
                repeat
                    Customer."Customer Category_PKT" := CustomerCategory.No;
                    Customer.Modify();
                until Customer.Next() = 0;
        end;
    end;

    //Returns the number of Customers without an assigned Customer Category
    procedure GetTotalCustomersWithoutCategory(): Integer
    var
        Customer: record Customer;
    begin
        Customer.SetRange("Customer Category_PKT", '');
        exit(customer.Count());
    end;

    procedure GetSalesAmount(CustomerCategoryCode: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
        Customer: record Customer;
        TotalAmount: Decimal;
    begin
        Customer.SetCurrentKey("Customer Category_PKT");
        Customer.SetRange("Customer Category_PKT", CustomerCategoryCode);
        if Customer.FindSet() then
            repeat
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Sell-to Customer No.", Customer."No.");
                if SalesLine.FindSet() then
                    repeat
                        TotalAmount += SalesLine."Line Amount";
                    until SalesLine.Next() = 0;
            until Customer.Next() = 0;

        exit(TotalAmount);
    end;
}