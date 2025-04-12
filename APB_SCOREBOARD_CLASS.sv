package APB_Scoreboard_Class_pkg;
import APB_Sequence_Class_pkg::*;
import shared_pkg::*;



class APB_Scoreboard_Class;
int right_count,wrong_count;
logic                          PREADY_Expected;
logic [DATA_WIDTH-1 : 0]       PRDATA_Expected;
APB_Sequence_Class seq1 = new();


task  refrence_model();
//To be added
endtask 

task  scoreboard(APB_Sequence_Class seq2);
seq1 = seq2;
refrence_model();
//To be continued


endtask //


endclass //APB_Scoreboard_Class
    
endpackage