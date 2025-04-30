package APB_Sequence_Class_pkg;
import shared_pkg::*;

class APB_Sequence_Class;

 rand   logic PRESETn;  

// Slave FROM Master
 rand   logic [ADDR_WIDTH-1 : 0]     	PADDR    ;
 rand   logic                        	PWRITE   ;
 rand   logic [DATA_WIDTH-1 : 0]     	PWDATA   ;
 rand   logic                        	PENABLE  ;
 rand   logic                           PSELx    ;

// Slave TO Master
 rand   logic                          PREADY    ;
 rand   logic [DATA_WIDTH-1 : 0]       PRDATA    ;

/*
1. Assert PRESETn less often    >>              High most of the time 
2. PENABLE and PSELx to be 1 most of the time
3. PWRITE to have equal distribution between read and write
4. PADDR to have addresses of the registers
*/

constraint c{ 

PRESETn dist {0:/10       ,1:/90};
PENABLE dist {0:/10       ,1:/90};
PSELx   dist {0:/10       ,1:/90};
PWRITE  dist {0:/50       ,1:/50};
PADDR   dist {
16'h0000:=10,
16'h0040:=10,
16'h0080:=10,
16'h00c0:=10,
16'h0100:=10,
16'h0140:=10,
16'h0180:=10,
16'h01c0:=10,
16'h0200:=10,
16'h0240:=10,
16'h0280:=10,
16'h02c0:=10,
16'h0300:=10,
16'h0340:=10,
16'h0380:=10,
16'h03c0:=10
};

}

endclass //APB_Sequence_Class


endpackage