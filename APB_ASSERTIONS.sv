module APB_SVA (wrapper_if.DUT Iff);
//WE Have 5 SECNARIOS
//RESET, Read, Write with and without strope
//we need assert property and cover that property

// RESET, Remeber that the reset is active low

always_comb begin 
    if (~Iff.PRESETn) begin
        assert_rst: assert final (Iff.PRDATA == 0 && Iff.PREADY ==0);
        cover_rst: cover final (Iff.PRDATA == 0 && Iff.PREADY ==0);
    end
end

function bit isinside_range(logic [15:0] PADDR);
 return (PADDR inside{16'h0000,16'h0040,16'h0080,
        16'h00c0,16'h0100,16'h0140,16'h0180,16'h01c0,16'h0200,
        16'h0240,16'h0280,16'h02c0,16'h0300,16'h0340,16'h0380,16'h03c0});
endfunction

//Write
ap2: assert property (@(posedge Iff.PCLK) disable iff (!Iff.PRESETn)(isinside_range(Iff.PADDR) && Iff.PSELx && Iff.PENABLE && Iff.PWRITE && !Iff.PREADY)|-> ##[1:3] (Iff.PREADY));
cp2: cover  property (@(posedge Iff.PCLK) disable iff (!Iff.PRESETn)(isinside_range(Iff.PADDR) && Iff.PSELx && Iff.PENABLE && Iff.PWRITE && !Iff.PREADY)|-> ##[1:3] (Iff.PREADY));
//READ
ap3: assert property (@(posedge Iff.PCLK) disable iff (!Iff.PRESETn)(isinside_range(Iff.PADDR) && Iff.PSELx && Iff.PENABLE && ~Iff.PWRITE && !Iff.PREADY)|-> ##[1:3] (Iff.PREADY));// && (Iff.PRDATA!=0) we may read data that's equal to zero
cp3: cover  property (@(posedge Iff.PCLK) disable iff (!Iff.PRESETn)(isinside_range(Iff.PADDR) && Iff.PSELx && Iff.PENABLE && ~Iff.PWRITE && !Iff.PREADY)|-> ##[1:3] (Iff.PREADY));// && (Iff.PRDATA!=0) we may read data that's equal to zero
endmodule