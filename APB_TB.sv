import APB_Sequence_Class_pkg::*;
import APB_Monitor_Class_pkg::*;
import shared_pkg::*;

module APB_TB (wrapper_if.TEST Iff);
integer start_time;

APB_Sequence_Class O1 = new();
APB_Monitor_Class O2 = new();
initial begin
    //WE Begin with some directed tests to get confident then proceed with random testing
    //RESET
    Iff.PRESETn = 0;
    O1.PRESETn = Iff.PRESETn;
    repeat(3) @(negedge Iff.PCLK);
    O1.PREADY= Iff.PREADY;
    O1.PRDATA= Iff.PRDATA;
    O2.monitor(O1);
    Iff.PRESETn = 1;
    O1.PRESETn = Iff.PRESETn;
    O1.c.constraint_mode(0);
    repeat (1000) begin
    assert (O1.randomize()); 
    //Setup phase
    Iff.PADDR  = O1.PADDR ;
    Iff.PWRITE = 1;         //O1.PWRITE
        O1.PWRITE = 1;
    Iff.PWDATA = O1.PWDATA;
    Iff.PSELx  = 1 ;
        O1.PSELx = 1;
    Iff.PENABLE= 0;
        O1.PENABLE =0;
    @(negedge Iff.PCLK);
     Iff.PENABLE= 1;
        O1.PENABLE =1;
    start_time = $time;
    forever begin
    @(negedge Iff.PCLK);
     if (Iff.PREADY == 1 || ($time - start_time > 100)) break;
    end
 
    O1.PREADY = Iff.PREADY;
    O1.PRDATA = Iff.PRDATA;
    O2.monitor(O1);
    @(negedge Iff.PCLK);
    end

    O1.c.constraint_mode(1);
        repeat (1000) begin
    assert (O1.randomize()); 
    //Setup phase
    Iff.PADDR  = O1.PADDR ;
    Iff.PWRITE = 1;         //O1.PWRITE
        O1.PWRITE = 1;
    Iff.PWDATA = O1.PWDATA;
    Iff.PSELx  = 1 ;
        O1.PSELx = 1;
    Iff.PENABLE= 0;
        O1.PENABLE =0;
    @(negedge Iff.PCLK);
     Iff.PENABLE= 1;
        O1.PENABLE =1;
    start_time = $time;
    forever begin
    @(negedge Iff.PCLK);
     if (Iff.PREADY == 1 || ($time - start_time > 100)) break;
    end
    O1.PREADY = Iff.PREADY;
    O1.PRDATA = Iff.PRDATA;
    O2.monitor(O1);
    @(negedge Iff.PCLK);
    end
    //We know write in all RF, let's read only in sequence

  repeat (500) begin
    assert (O1.randomize()); 
    //Setup phase
    Iff.PRESETn = O1.PRESETn;
    Iff.PADDR  = O1.PADDR;
    Iff.PWRITE = 0;
        O1.PWRITE = 0 ;
    Iff.PWDATA = O1.PWDATA;
    Iff.PSELx  = 1;
            O1.PSELx= 1;
    Iff.PENABLE = 0;
         O1.PENABLE = 0;
    @(negedge Iff.PCLK);
     Iff.PENABLE= 1;
        O1.PENABLE =1;
    start_time = $time;
    forever begin
    @(negedge Iff.PCLK);
     if (Iff.PREADY == 1 || ($time - start_time > 300)) break;
    end
    O1.PREADY = Iff.PREADY;
    O1.PRDATA = Iff.PRDATA;
    O2.monitor(O1);

    @(negedge Iff.PCLK);

    end 

    Iff.PRESETn = 0;
    O1.PRESETn = Iff.PRESETn;
    repeat(3) @(negedge Iff.PCLK);
    O1.PREADY= Iff.PREADY;
    O1.PRDATA= Iff.PRDATA;
    
//READ AND WRITE
$display("Time at the third Testcases run: %t", $time);
repeat (500) begin
  assert (O1.randomize());
  Iff.PRESETn = O1.PRESETn;
  Iff.PADDR   = O1.PADDR;
  Iff.PWRITE  = O1.PWRITE;
  Iff.PWDATA  = O1.PWDATA;
  Iff.PSELx   = O1.PSELx;
  Iff.PENABLE = 0;
   O1.PENABLE=0;
  @(negedge Iff.PCLK);

  // Access Phase 
  Iff.PENABLE = 1;
    O1.PENABLE=1;
  start_time = $time;
  // wait for PREADY
  forever begin
    @(negedge Iff.PCLK);
    if (Iff.PREADY == 1)
      break;
    else if ($time - start_time > 300) begin
      $display("Timeout at %t. Resetting...", $time);
      Iff.PRESETn = 0;
      O1.PRESETn =0;
      Iff.PSELx   = 0;
      O1.PSELx =0;
      @(negedge Iff.PCLK);
      Iff.PRESETn = 1;
      O1.PRESETn =1;
      @(negedge Iff.PCLK);
      break;
    end
  end

  // Capture DUT outputs after transaction
  O1.PREADY = Iff.PREADY;
  O1.PRDATA = Iff.PRDATA;

  //  Display transaction info
  $display("Reset: %h | Addr: %h | PWRITE: %h | PWDATA: %h | PSELx: %h | PENABLE: %h | PREADY: %h | PRDATA: %h @ %0t",
           Iff.PRESETn, Iff.PADDR, Iff.PWRITE, Iff.PWDATA, Iff.PSELx, Iff.PENABLE, Iff.PREADY, Iff.PRDATA, $time);

  O2.monitor(O1);

  //  Transaction done — deassert control signals
  @(negedge Iff.PCLK);
  Iff.PSELx   = 0;
  O1.PSELx =0;
  Iff.PENABLE = 0;
  O1.PENABLE =0;
end
$stop; 
end

endmodule