module RAM
(
	 ram_wdata,
    ram_addr,
    ram_avalid,
    ram_rnw,

    ram_rdata,
    ram_ack,
    ram_clk
);
    parameter       ADDR_SIZE   = 12;      
    parameter       WORD_SIZE   = 8;     
    parameter       CPU_WORD_SIZE   = 32;  
    parameter       CPU_ADDR_WIDTH   = 32;  
    parameter       DATA_SIZE   = 128;  
	parameter BVAL_WIDTH = 4;	 
    parameter   		DELAY       = 5; 
    localparam ITER_COUNT = DATA_SIZE / WORD_SIZE;
	 
	
	 

	 
    reg [DATA_SIZE-1:0] data;
    reg [ADDR_SIZE-1:0] addr;
	 
	 //RAM IF
	 input [WORD_SIZE-1:0]   ram_wdata;
    input [ADDR_SIZE-1:0]   ram_addr;
    input                   ram_avalid;
    input                   ram_rnw;
	 input						 ram_clk;

    output reg [WORD_SIZE-1:0] ram_rdata;
    output reg                 ram_ack;
	 


    initial begin
        //ram_clk = 0;
        ram_rdata = 0;
        ram_ack = 0;
        data = 0;
        addr = 0;
		  
		  
    end
	 
	
		
	//RAM LOGIC
    always @(posedge ram_avalid) begin
        if(!ram_rnw) begin 
            addr <= ram_addr;
            repeat (ITER_COUNT) begin
                @(posedge ram_clk); 
						data <= {ram_wdata, data[127:8]}; 
            end
            ram_ack <= 1;
            @(posedge ram_clk);
            ram_ack <= 0;
            //$display("[RAM %0t] WRITE ok! addr = %0h, data = %0h", $time, ram_addr, data);
        end
        else begin
            addr = ram_addr;
            #(DELAY);
            data = {$random, $random, $random, $random};
            //$display("[RAM %0t] READ ok! addr = %0h, data = %0h", $time, ram_addr, data);
            repeat(ITER_COUNT) begin
                @(posedge ram_clk);
                ram_ack = 1;
                ram_rdata = data[WORD_SIZE-1:0];
                data = (data >> WORD_SIZE);
            end
            @(posedge ram_clk);
            ram_ack = 0;
        end
    end

endmodule
