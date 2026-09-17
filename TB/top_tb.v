module top_tb();
reg hclk,hresetn;
wire [31:0]haddr,hwdata,hrdata,paddr,pwdata,pwdata_out,paddr_out,prdata;
wire [1:0]hresp,htrans;
wire [2:0]psel,psel_out;
wire hreadyout,hwrite,hreadyin,penable,pwrite_out,penable_out;

ahb_master ahb(hclk,hresetn,hreadyout,hrdata,haddr,hwdata,hwrite,hreadyin,htrans);
apb_interface apb(pwrite,penable,psel,paddr,pwdata,pwrite_out,penable_out,psel_out,paddr_out,pwdata_out,prdata);
bridge_top bridge(hclk,hresetn,hwrite,hreadyin,hwdata,haddr,prdata,htrans,pwrite,penable,hreadyout,psel,paddr,pwdata,hrdata,hresp); 

initial
begin
	hclk=1'b0;
	forever #10 hclk=~hclk;
end

task reset();
begin
	@(negedge hclk)
		hresetn=1'b0;
	@(negedge hclk)
		hresetn=1'b1;
end
endtask

initial
begin
reset;
//ahb.single_write();
ahb.burst_write();
//ahb.single_read();
#200 $finish;
end
endmodule

