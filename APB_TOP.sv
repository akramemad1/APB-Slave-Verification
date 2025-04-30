module APB_TOP ();
bit PCLK;

always #10 PCLK= ~PCLK;

wrapper_if Iff (PCLK);

APB_Wrapper apb_wrapper(Iff);

APB_TB apb_tb(Iff);       
bind APB_Wrapper APB_SVA sva(Iff);

endmodule