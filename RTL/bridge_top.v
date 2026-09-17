module bridge_top(input hclk,hresetn,hwrite,hreadyin,
						input [31:0]hwdata,haddr,prdata,
						input [1:0]htrans,
						output pwrite,penable,hreadyout,
						output [2:0]psel,
						output [31:0]paddr,pwdata,hrdata, output [1:0]hresp);
					wire valid;
					wire [31:0]hwdata1,hwdata2,haddr1,haddr2;
					wire [2:0]temp_selx;
					
		ahb_slave ahb(hclk,hresetn,hwrite,hreadyin,htrans,haddr,hwdata,prdata,hresp,hrdata,valid,haddr1,haddr2,hwdata1,hwdata2,hwritereg,tempselx);
					
		apb_controller apb(hclk,hresetn,hwrite,hwritereg,valid,haddr,haddr1,haddr2,hwdata,hwdata1,hwdata2,prdata,tempselx,pwrite,penable,psel,hreadyout,paddr,pwdata);

endmodule