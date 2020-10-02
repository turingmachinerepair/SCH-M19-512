`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:43 06/08/2020 
// Design Name: 
// Module Name:    test_ram_model 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test_ram_model(
//RAM MODEL
	ram_wdata,
    ram_addr,
    ram_avalid,
    ram_rnw,

    ram_rdata,
    ram_ack,
    ram_clk,
//CPU MODEL
	sys_addr,
	sys_wdata,
	sys_rdata,
	sys_rd,
	sys_wr,
	sys_ack,
	sys_bval,
	
	rst,
	cpu_clk,
	cache_clk,
	ram_clk
);
integer command_ct;
real optime;
integer f;
integer ramct;
integer i;


    parameter       ADDR_SIZE   = 12;      
    parameter       WORD_SIZE   = 8;  
    parameter       DATA_SIZE   = 128;    
    parameter   		DELAY       = 5; 
	 
	 parameter CPU_ADDR_WIDTH = 16;
	 parameter CPU_WORD_SIZE = 32;
	 parameter BVAL_WIDTH = 4;
    localparam ITER_COUNT = DATA_SIZE / WORD_SIZE;
	 
	 //test1
	localparam CPU_CLK_PERIOD = 8;	localparam CACHE_CLK_PERIOD = 21;	localparam RAM_CLK_PERIOD = 58;
	
	//test2
	//localparam CPU_CLK_PERIOD = 58;	localparam CACHE_CLK_PERIOD = 21;	localparam RAM_CLK_PERIOD = 8;
	
	localparam INTEROP_DELAY = 10*RAM_CLK_PERIOD;
	localparam RAM_DELAY = 10*RAM_CLK_PERIOD;
	 
    reg [DATA_SIZE-1:0] data;
	 reg [CPU_WORD_SIZE-1:0] data_check;
    reg [ADDR_SIZE-1:0] addr;
	 
	 //RAM IF
	 input [WORD_SIZE-1:0]   ram_wdata;
    input [ADDR_SIZE-1:0]   ram_addr;
    input                   ram_avalid;
    input                   ram_rnw;

    output reg [WORD_SIZE-1:0] ram_rdata;
    output reg                 ram_ack;
	 
	 	 //CPU IF
	output		reg	[CPU_ADDR_WIDTH-1:0] sys_addr;
	output		reg	[CPU_WORD_SIZE-1:0] sys_wdata;
	input	wire	[CPU_WORD_SIZE-1:0] sys_rdata;
	output		reg	[BVAL_WIDTH-1:0]	sys_bval;
	output		reg	sys_rd;
	output		reg	sys_wr;
	input	wire	sys_ack;
	
	output reg rst;
	output reg cpu_clk;
	output reg cache_clk;
	output reg ram_clk;
	
 //параметры памяти
	 localparam CACHE_SIZE = 2048;
	 localparam RAM_SIZE = 65536;
	 
	 //параметры теста 
	 //32 кб данных = 65536 процессорных слов => 65536 команд
	 localparam COMMAND_COUNT = 65536;
	 //предел адресов: 1 - кеш, 2 - два кеша, 3 - четыре кеша, 4 - ОП
	 localparam LIMIT1 = CACHE_SIZE;
	 localparam LIMIT2 = LIMIT1*2;
	 localparam LIMIT3 = LIMIT2*2;
	 localparam LIMIT4 = RAM_SIZE;
	 
	 localparam EFFECTIVE_LIMIT = LIMIT1 ;
	 
	 reg [WORD_SIZE-1:0] ram_memory[RAM_SIZE-1:0];
	 reg [CPU_ADDR_WIDTH-1:0] ram_addr_buf;
	 reg [CPU_ADDR_WIDTH-1:0] expected_ram_addr;
	 //initial states
    initial begin
        //ram_clk = 0;
        ram_rdata = 0;
        ram_ack = 0;
        data = 0;
        addr = 0;
		  sys_addr = 0;
		  sys_wdata = 0;
		  sys_bval = 0;
		  sys_rd = 0;
		  sys_wr = 0;
		  
		  cpu_clk = 0;
		  cache_clk = 0;
		  ram_clk = 0;
		  rst = 0;
		  data_check = 0;
		  ramct = 0;
		  
		  for(i=0; i<RAM_SIZE; i=i+1)
		  begin
			ram_memory[i] = $random;
		  end
    end
	 
	 //clock logic
	always begin
		#(CPU_CLK_PERIOD/2) cpu_clk = ~cpu_clk;
	end
	
	always begin
		#(CACHE_CLK_PERIOD/2) cache_clk = ~cache_clk;
	end
	
	always begin
		#(RAM_CLK_PERIOD/2) ram_clk = ~ram_clk;
	end
      
		
	//CPU LOGIC
	 initial begin
		$timeformat(-9, 3, "", 8);
		#(10*RAM_CLK_PERIOD)
		rst = 1;
		#RAM_CLK_PERIOD
		rst = 0;
		#(60*RAM_CLK_PERIOD);
		$display("[%0t] Start test\n", $time);
    
		f = $fopen("test1.txt","w");
		
		$fwrite(f,"ADDR,ELAPSED\n");
		for(command_ct = 0; command_ct< COMMAND_COUNT; command_ct = command_ct+1)
		begin
			//$display("Test #%d",command_ct);
			optime = $realtime;
			sys_addr = $random % EFFECTIVE_LIMIT;
			
			//expected_ram_addr = ((sys_addr>>2)<<2);
			expected_ram_addr = {sys_addr[15:2], 2'b00};
			data_check = {ram_memory[expected_ram_addr+3],
			ram_memory[expected_ram_addr+2],
			ram_memory[expected_ram_addr+1], 
			ram_memory[expected_ram_addr]};
			
			sys_rd = 1;
			#CPU_CLK_PERIOD
			sys_rd = 0;
			fork : wait_test2
			  begin
				 #10_000; //#10ms
				 disable wait_test2;
			  end
			  begin
				 @(posedge sys_ack);
				 disable wait_test2;
			  end
			join
			
			if( sys_rdata != data_check )
			begin
				$display("Test failed at %h must be %h got %h\n",sys_addr,
					{ram_memory[expected_ram_addr+4],data_check,ram_memory[expected_ram_addr-1]}, 
					sys_rdata);
					$stop;
			end
			#10
			optime = $time - optime;
			$fwrite(f,"%d,%t\n",sys_addr,optime);
		end
		$fwrite(f,"RAM OPS:%d",ramct);
		$display("[%0t] End test\n", $time);
		$fclose(f);  
	 end

	//RAM LOGIC
    always @(posedge ram_avalid) begin
		ramct= ramct+1;
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
				ram_addr_buf = addr;
				ram_addr_buf = ram_addr_buf<<4;
            #(DELAY);
            //data = {$random, $random, $random, $random};
				data = { ram_memory[ram_addr_buf+15], 
							ram_memory[ram_addr_buf+14],
							ram_memory[ram_addr_buf+13],
							ram_memory[ram_addr_buf+12],
							ram_memory[ram_addr_buf+11],
							ram_memory[ram_addr_buf+10],
							ram_memory[ram_addr_buf+9],
							ram_memory[ram_addr_buf+8],
							ram_memory[ram_addr_buf+7], 
							ram_memory[ram_addr_buf+6],
							ram_memory[ram_addr_buf+5],
							ram_memory[ram_addr_buf+4],
							ram_memory[ram_addr_buf+3],
							ram_memory[ram_addr_buf+2],
							ram_memory[ram_addr_buf+1],
							ram_memory[ram_addr_buf]};
				
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
