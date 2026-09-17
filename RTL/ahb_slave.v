module ahb_slave(hclk,hresetn,hwrite,hreadyin,htrans,haddr,hwdata,prdata,hresp,hrdata,valid,haddr1,haddr2,hwdata1,hwdata2,hwritereg,hwritereg1,tempselx);

input hclk,hresetn,hwrite,hreadyin;
input [1:0]htrans;
input [31:0]haddr,hwdata,prdata;
output [1:0]hresp;
output reg [31:0] haddr1,haddr2,hwdata1,hwdata2;
output reg [2:0]tempselx;
output reg valid,hwritereg,hwritereg1;
output [31:0]hrdata;

always @(posedge hclk)
begin
			if(!hresetn)
						begin
							haddr1 <= 0;
							haddr2 <= 0;
						end
			else
						begin
							haddr1 <= haddr;
							haddr2 <= haddr1;
						end
end

//Pipeine logic for the data
always @(posedge hclk)
begin
			if(!hresetn)
						begin
							hwdata1 <= 0;
							hwdata2 <= 0;
						end
			else
						begin
							hwdata1 <= hwdata;
							hwdata2 <= hwdata1;
						end
end
	
//Pipeline logic for the write signal
always @(posedge hclk)
begin
			if(!hresetn)
						begin
							hwritereg <= 0;
							hwritereg1 <= 0;
						end
			else
						begin
							hwritereg <= hwrite;
							hwritereg1 <= hwritereg;
						end
end

//Select the peripheral
always@(*)
begin
			if(haddr >= 32'h8000_0000 && haddr < 32'h8400_0000)
						tempselx = 3'b001;
			else if(haddr >= 32'h8400_0000 && haddr < 32'h8800_0000)
						tempselx = 3'b010;
			else if(haddr >= 32'h8800_0000 && haddr < 32'h8c00_0000)
						tempselx = 3'b100;
			else
						tempselx = 3'b000;
end

//Logic for the valid signal
always@(*)
begin
			if((haddr >= 32'h8000_0000 && haddr < 32'h8c00_0000) && (hreadyin == 1) && (htrans == 2'b10 || htrans == 2'b11))
						valid = 1'b1;
			else
						valid = 1'b0;
end

assign hresp = 2'd0;
assign hrdata = prdata;

endmodule
			