interface wrapper_if#(parameter DATA_WIDTH = 32,parameter ADDR_WIDTH = 16) (PCLK);

 input bit PCLK;
 logic PRESETn;  

// Slave FROM Master
    logic [ADDR_WIDTH-1 : 0]     	PADDR    ;
    logic                        	PWRITE   ;
    logic [DATA_WIDTH-1 : 0]     	PWDATA   ;
    logic                        	PENABLE  ;
    logic                           PSELx    ;

// Slave TO Master
    logic                          PREADY    ;
    logic [DATA_WIDTH-1 : 0]       PRDATA    ;

modport DUT (
input PCLK,PRESETn,PWRITE,PENABLE,PSELx,PADDR,PWDATA,
output PREADY,PRDATA 
);

modport TEST (
output PRESETn,PWRITE,PENABLE,PSELx,PADDR,PWDATA,
input PREADY,PCLK,PRDATA 
);





endinterface //slave_if(PCLK)
