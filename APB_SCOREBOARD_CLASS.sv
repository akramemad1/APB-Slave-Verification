package APB_Scoreboard_Class_pkg;
import APB_Sequence_Class_pkg::*;
import shared_pkg::*;



class APB_Scoreboard_Class;
 logic [DATA_WIDTH-1:0] a_array [logic [ADDR_WIDTH-1:0]]; //key is a Logic (inside Brackets) 
 int right_count,wrong_count;
 logic                          PREADY_Expected;
 logic [DATA_WIDTH-1 : 0]       PRDATA_Expected, PRDATA_TEMP;
 APB_Sequence_Class seq1 = new();
 bit compare;

 task  refrence_model(); // Integrity CHECK

 if(!seq1.PRESETn)begin
    PREADY_Expected=0;
    PRDATA_Expected=0; 
    compare = 1;
  end else if(seq1.PSELx && seq1.PENABLE && seq1.PREADY) begin
     if (seq1.PWRITE == 1) begin
        if (seq1.PADDR inside{16'h0000,16'h0040,16'h0080,
        16'h00c0,16'h0100,16'h0140,16'h0180,16'h01c0,16'h0200,
        16'h0240,16'h0280,16'h02c0,16'h0300,16'h0340,16'h0380,16'h03c0
        })begin
         a_array[seq1.PADDR] = seq1.PWDATA;
         compare =0;
        end
     end else begin
        if(a_array.exists(seq1.PADDR)) begin
        PRDATA_Expected = a_array[seq1.PADDR];
        PRDATA_TEMP = PRDATA_Expected;
        compare =1;
        end else begin
            compare = 0;
        end
     end
  end else begin
   PRDATA_Expected = 0;
   compare = 1;
  end
endtask 

task  scoreboard(APB_Sequence_Class seq2);
seq1 = seq2;
refrence_model();

 if (compare) begin           // Only compare during a read transaction
    if (seq1.PRDATA === PRDATA_Expected) begin
    $display("Read match at %h: %h, EXPECTED: %h ", seq1.PADDR, seq1.PRDATA, PRDATA_Expected);
    right_count++;        
    $display("Right count = %h , Wrong count = %h", right_count, wrong_count);
    end else begin
    $display("Read data mismatch at %h: expected %h, got %h,Address:%h Time:%0t ",
     seq1.PADDR, PRDATA_Expected, seq1.PRDATA,seq1.PADDR , $time); //Could be due to read or write problem
    wrong_count++;
    $display("Right count = %h , Wrong count = %h", right_count, wrong_count);
    end
 end else begin
   $display("NOTHING HAPPENED");
 end

endtask


endclass //APB_Scoreboard_Class
    
endpackage 