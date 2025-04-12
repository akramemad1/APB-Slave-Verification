package APB_Monitor_Class_pkg;
import APB_Sequence_Class_pkg::*;
import APB_Coverage_Class_pkg::*;
import APB_Scoreboard_Class_pkg::*;

class APB_Monitor_Class;


APB_Scoreboard_Class APB_Scoreboard_Object = new();
APB_Coverage_Class APB_Coverage_Object = new();


task  monitor(APB_Sequence_Class seq1);

APB_Scoreboard_Object.scoreboard(seq1);
APB_Coverage_Object.sample_data(seq1);

    
endtask //



endclass //APB_Monitor_class





endpackage