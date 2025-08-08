module fsm #(
    parameter ADDR_W = 10
    ) (
    input                           clk,
    input                           start,
    input                           reset,
    output logic                    load_weights,   
    output logic                    load_inputs,    
    output logic                    store_outputs, 
    output logic                    ren, 
    output logic                    wen, 
    output logic [ADDR_W -1:0]      address_o, 
    input                           valid_out 
);

reg work_in_progress    ;
reg waiting_valid        ;

always @(posedge clk) begin
    if (reset) begin
        load_weights        <= '0;
        load_inputs         <= '0;
        store_outputs       <= '0;
        work_in_progress    <= '0;
        address_o           <= '0;
        ren                 <= '0;
        wen                 <= '0;
    end 
    else if (work_in_progress) 
    begin
        if (load_weights) begin
            address_o           <=  address_o + 1 ;
            ren                 <=  1;
            wen                 <= '0;
            if (address_o == 16) 
            begin
                load_weights    <= '0;
                load_inputs     <=  1;
            end
        end 
        else if (load_inputs) 
        begin
            address_o           <=  address_o + 1 ;
            ren                 <=  1;
            wen                 <= '0;
            if (address_o == 32) 
            begin
                load_inputs     <= '0;
                waiting_valid   <=  1;
            end
        end
        else if (valid_out && waiting_valid)
        begin
            store_outputs       <= 1 ;
            waiting_valid       <= 0 ;
            address_o           <= 32;
            wen                 <= '0;
            ren                 <= '0;

        end
        else if (store_outputs) 
        begin
            wen                 <=  1;
            ren                 <= '0;
            address_o           <=  address_o + 1 ;
            if (address_o == 48) 
            begin
                store_outputs   <= '0;
                work_in_progress<= '0;
                ren             <= '0;
                wen             <= '0;

            end
        end
        else if (!waiting_valid)
        begin
            load_weights        <= '0;
            address_o           <=  address_o ;
            ren                 <= '0;
            wen                 <= '0;
        end
    end else if (start)
    begin
        work_in_progress        <=  1;
        load_weights            <=  1;
        ren                     <=  1;
        wen                     <= '0;
    end
end    
endmodule