package shared_pkg;
	parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter NO_SLAVES  = 1;	
    int clk_cycle = 4;
	
	// States type using onehot encoding
	typedef enum logic [2:0] {
	IDLE   = 3'b001,
	SETUP  = 3'b011,
	ENABLE = 3'b010,
	READY = 3'b110} state_e;

	parameter ACTIVE_RESET = 2;	
	parameter READ_OP = 30;	
	parameter WRITE_OP = 70;	
	parameter MAX_DATA = 32'hFFFF_FFFF;	
	parameter MIN_DATA = 32'h0000_0000;	

	parameter READ_ACTIVE_PENABLE_LOOP 	  = 12;	
	parameter READ_INACTIVE_PENABLE_LOOP  = 2;	
	parameter WRITE_ACTIVE_PENABLE_LOOP   = 12;	
	parameter WRITE_INACTIVE_PENABLE_LOOP = 2;	
	parameter TOGGLE_LOOP   = 5;
	parameter RANDOM_LOOP   = 10;
endpackage : shared_pkg

module RegisterFile #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16			
 ) (
 // Global Sinals
	input wire  						clk,
    input wire							rstn,  

    input wire [ADDR_WIDTH-1 : 0]   	addr,
    input wire [DATA_WIDTH-1 : 0]   	write_data,
    input wire                      	wr,
    input wire 							enable,

    output reg [DATA_WIDTH-1 : 0]   	read_data
    // output 	                      		RegSLVERR,
    // output reg                      	RegREADY      
 );

	// RegSLVERR is pripherable 
	assign RegSLVERR = 0;
		
	// Registers
	reg [DATA_WIDTH-1:0] SYS_STATUS_REG;
	reg [DATA_WIDTH-1:0] INT_CTRL_REG;
	reg [DATA_WIDTH-1:0] DEV_ID_REG;
	reg [DATA_WIDTH-1:0] MEM_CTRL_REG;
	reg [DATA_WIDTH-1:0] TEMP_SENSOR_REG;
	reg [DATA_WIDTH-1:0] ADC_CTRL_REG;
	reg [DATA_WIDTH-1:0] DBG_CTRL_REG;
	reg [DATA_WIDTH-1:0] GPIO_DATA_REG;
	reg [DATA_WIDTH-1:0] DAC_OUTPUT_REG;
	reg [DATA_WIDTH-1:0] VOLTAGE_CTRL_REG;
	reg [DATA_WIDTH-1:0] CLK_CONFIG_REG;
	reg [DATA_WIDTH-1:0] TIMER_COUNT_REG;
	reg [DATA_WIDTH-1:0] INPUT_DATA_REG;
	reg [DATA_WIDTH-1:0] OUTPUT_DATA_REG;
	reg [DATA_WIDTH-1:0] DMA_CTRL_REG;
	reg [DATA_WIDTH-1:0] SYS_CTRL_REG;
	always @(*) begin
		if (~wr & enable) begin
			case (addr)
				16'h0000: read_data <= SYS_STATUS_REG;
				16'h0040: read_data <= INT_CTRL_REG;
				16'h0080: read_data <= DEV_ID_REG;
				16'h00c0: read_data <= MEM_CTRL_REG;
				16'h0100: read_data <= TEMP_SENSOR_REG;
				16'h0140: read_data <= ADC_CTRL_REG;
				16'h0180: read_data <= DBG_CTRL_REG;
				16'h01c0: read_data <= GPIO_DATA_REG;
				16'h0200: read_data <= DAC_OUTPUT_REG;
				16'h0240: read_data <= VOLTAGE_CTRL_REG;
				16'h0280: read_data <= CLK_CONFIG_REG;
				16'h02c0: read_data <= TIMER_COUNT_REG;
				16'h0300: read_data <= INPUT_DATA_REG;
				16'h0340: read_data <= OUTPUT_DATA_REG;
				16'h0380: read_data <= DMA_CTRL_REG;
				16'h03c0: read_data <= SYS_CTRL_REG;
			endcase
		end
		
	end

    always @(posedge clk or negedge rstn) begin
    	if(~rstn) begin
    		read_data <= 0;
    	end
        else if(enable) begin

        	if(wr) begin
            	case (addr)
            		16'h0000: SYS_STATUS_REG	<= write_data;
					16'h0040: INT_CTRL_REG		<= write_data;
					16'h0080: DEV_ID_REG		<= write_data;
					16'h00c0: MEM_CTRL_REG		<= write_data;
					16'h0100: TEMP_SENSOR_REG	<= write_data;
					16'h0140: ADC_CTRL_REG		<= write_data;
					16'h0180: DBG_CTRL_REG		<= write_data;
					16'h01c0: GPIO_DATA_REG	 	<= write_data;
					16'h0200: DAC_OUTPUT_REG	<= write_data;
					16'h0240: VOLTAGE_CTRL_REG	<= write_data;
					16'h0280: CLK_CONFIG_REG	<= write_data;
					16'h02c0: TIMER_COUNT_REG	<= write_data;
					16'h0300: INPUT_DATA_REG	<= write_data;
					16'h0340: OUTPUT_DATA_REG	<= write_data;
					16'h0380: DMA_CTRL_REG		<= write_data;
					16'h03c0: SYS_CTRL_REG		<= write_data;
            	endcase

            end
        end
        
    end
endmodule

module APB_Slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter SLAVE_ID = 4'b0001
 ) (
 // Global Sinals
    input PCLK                                 ,
    input PRESETn                              ,  

 // input SLAVE FROM MASTER  
    input [ADDR_WIDTH-1 : 0]     PADDR         ,
    input                        PWRITE        ,
    input [DATA_WIDTH-1 : 0]     PWDATA        ,
    input                        PENABLE       ,

 // input SLAVE FROM REG_FILE  
    input [DATA_WIDTH-1 : 0]     RegRDATA      ,
    input       PSELx         ,
  
 // output SLAVE TO MASTER  
    output reg                       PREADY    ,
    output reg [DATA_WIDTH-1 : 0]    PRDATA    ,

 // output SLAVE TO REG_FILE  
    output reg [ADDR_WIDTH-1 : 0]    RegADDR   ,
    output reg [DATA_WIDTH-1 : 0]    RegWDATA  ,
    output reg                       RegENABLE,
    output reg                       RegWRITE
 );
    
    import shared_pkg::*;
    state_e NextState, CurrentState;
    wire correct_slave;
    reg [3:0] address_encoding;
    assign correct_slave = PSELx && (SLAVE_ID === address_encoding);
 // Next State Logic
    always @(*) begin
        case (CurrentState)
            IDLE: begin
                if (correct_slave) begin
                    NextState <= SETUP;
                end
                else begin
                    NextState <= IDLE;
                end
            end
            SETUP: begin
                if (~correct_slave) begin 
                    NextState <= IDLE;
                end
                else if (PENABLE) begin
                    NextState <= ENABLE;
                end 
                else begin
                    NextState <= SETUP;
                end
            end
            ENABLE: begin
                NextState <= READY;
            end
            READY: begin
                if (correct_slave) begin 
                    NextState <= SETUP;
                end else begin
                    NextState <= IDLE;
                end
            end
            default: 
                NextState <= IDLE;
        endcase
    end

 // State Memory
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            CurrentState = IDLE;
        end else begin
            CurrentState = NextState;
        end
    end

    
 // output Logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            RegENABLE    <= 0;
            RegADDR      <= 0; 
            RegWRITE     <= 0;
            PREADY       <= 0;
            PRDATA       <= 0;
            RegWDATA     <= 0;
        end
        else begin
            case (CurrentState)
                IDLE: begin
                    RegENABLE <= 0;
                end 
                SETUP: begin
                    RegADDR <= PADDR;
                    RegWRITE <= PWRITE;
                    RegWDATA <= PWDATA;
                    RegENABLE <= 0;
                    PREADY <= 0;
                end 
                ENABLE: begin
                    RegENABLE <= PENABLE;
                    /*
                        RegENABLE <= 1;
                    */
                end
                READY: begin
                    PREADY <= 1;
                        PRDATA <= RegRDATA;
                end 
                default: begin
                    RegENABLE <= 0;
                    PREADY <= 0;
                end
            endcase
        end
    end

 wire [1:0] encoding;
 assign encoding = PADDR[ADDR_WIDTH-1:ADDR_WIDTH-2];
 // ADDRESS Decoding
    always @(*) begin
        if (PSELx) begin
            case (encoding)
                2'b00: address_encoding = 4'b0001; 
                2'b01: address_encoding = 4'b0010; 
                2'b10: address_encoding = 4'b0100; 
                2'b11: address_encoding = 4'b1000; 
                default: address_encoding = 4'b0000;
            endcase
        end else begin
            address_encoding = 0;
        end
    end
endmodule

module APB_Wrapper (wrapper_if.DUT Iff);
 // input Slave FROM RegisterFile
    wire [Iff.DATA_WIDTH-1 : 0]     RegRDATA    ;

 // output Slave TO RegisterFile
    wire [Iff.ADDR_WIDTH-1 : 0]    RegADDR      ;
    wire [Iff.DATA_WIDTH-1 : 0]    RegWDATA     ;
    wire                       RegWRITE     ;
    wire                       RegENABLE    ;

 RegisterFile #(
    .DATA_WIDTH(Iff.DATA_WIDTH) ,
    .ADDR_WIDTH(Iff.ADDR_WIDTH) 
 )reg_file(

    .clk(Iff.PCLK)              ,
    .rstn(Iff.PRESETn)          ,

    .addr(RegADDR)          ,
    .write_data(RegWDATA)   ,
    .wr(RegWRITE)           ,
    .enable(RegENABLE)      ,

    .read_data(RegRDATA)    
 );

 APB_Slave #(
    .DATA_WIDTH(Iff.DATA_WIDTH) ,
    .ADDR_WIDTH(Iff.ADDR_WIDTH) ,
    .SLAVE_ID(4'b0001)
 )apb_slave(
 // Global Sinals
    .PCLK(Iff.PCLK)             ,
    .PRESETn(Iff.PRESETn)       ,

 // input Slave FROM Master
    .PADDR(Iff.PADDR)           ,
    .PWRITE(Iff.PWRITE)         ,
    .PWDATA(Iff.PWDATA)         ,
    .PENABLE(Iff.PENABLE)       ,
 // input Slave FROM RegisterFile
    .RegRDATA(RegRDATA)     ,
    .PSELx(Iff.PSELx),
    .RegENABLE(RegENABLE),

 // output Slave TO Master
    .PREADY(Iff.PREADY)         ,
    .PRDATA(Iff.PRDATA)         ,

 // output Slave TO RegisterFile
    .RegADDR(RegADDR)       ,
    .RegWDATA(RegWDATA)     ,
    .RegWRITE(RegWRITE)
 );

endmodule