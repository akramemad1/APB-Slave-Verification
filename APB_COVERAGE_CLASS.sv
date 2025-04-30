package APB_Coverage_Class_pkg;
import APB_Sequence_Class_pkg::*;

class APB_Coverage_Class;


APB_Sequence_Class APB_Sequence_Object = new();

covergroup cg;
  cp_a:coverpoint APB_Sequence_Object.PADDR {
    bins addr_bins[16] = {16'h0000,16'h0040,16'h0080,16'h00c0,16'h0100,16'h0140,16'h0180,16'h01c0,16'h0200,16'h0240,16'h0280,16'h02c0,16'h0300,16'h0340,16'h0380,16'h03c0};
}
 cp_b: coverpoint APB_Sequence_Object.PSELx {
    bins psel_low = {0};
    bins psel_high = {1};
  }

  cp_c:coverpoint APB_Sequence_Object.PWRITE {
    bins write = {1};
    bins read  = {0};
  }

  cross cp_a, cp_b, cp_c;

endgroup


function void sample_data(APB_Sequence_Class O1);
  APB_Sequence_Object = O1;
  cg.sample();
    
endfunction

function new();
    cg=new();
    
endfunction


endclass //APB_Coverage_Class

    
endpackage