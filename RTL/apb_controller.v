module apb_controller(hclk,hresetn,hwrite,hwritereg,valid,haddr,haddr1,haddr2,hwdata,hwdata1,hwdata2,prdata,tempselx,pwrite,penable,psel,hreadyout,paddr,pwdata);
input valid,hwritereg,hclk,hresetn,hwrite;
input [31:0]haddr1,haddr2,haddr,hwdata1,hwdata2,hwdata,prdata;
input [2:0]tempselx;
output reg pwrite,penable;
output reg [2:0]psel;
output reg hreadyout;
output reg [31:0]pwdata,paddr;

parameter st_idle = 3'b000,
				st_wwait = 3'b001,
				st_write = 3'b010,
				st_writep = 3'b011,
				st_wenablep = 3'b100,
				st_wenable = 3'b101,
				st_read = 3'b110,
				st_renable = 3'b111;
reg [2:0]state,next_state;
reg [31:0]paddr_temp,pwdata_temp;
reg penable_temp,pwrite_temp,hreadyout_temp;
reg [2:0]psel_temp;

//present state logic
always@(posedge hclk)
begin
	if(!hresetn)
		state<=st_idle;
	else
		state<=next_state;
end

//next state logic
always@(*)
begin
	case(state)
		st_idle		:	begin
									if((valid == 1'b1) && (hwrite == 1'b1))
										next_state = st_wwait;
									else if((valid == 1'b1) && (hwrite == 1'b0))
										next_state = st_read;
									else
										next_state = st_idle;
							end
		st_wwait		: 	begin
									if(valid == 1'b1)
										next_state = st_writep;
									else
										next_state = st_write;
							end
		st_writep	: 	begin
									next_state = st_wenablep;
							end
		st_write		:	begin
									if(valid == 1'b1)
										next_state = st_wenablep;
									else
										next_state = st_wenable;
							end
		st_wenablep	:	begin
									if((valid == 1'b1) && hwritereg)
										next_state = st_writep;
									else if(~hwritereg)
										next_state = st_read;
									else if((valid == 1'b0))
										next_state = st_write;
									else
										next_state = st_wenablep;
							end
		st_wenable	:	begin
									if((valid == 1'b1) && ~hwrite)
										next_state = st_read;
									else if(~valid)
										next_state = st_idle;
									else
										next_state = st_wenable;
							end
		st_read		:  begin
									next_state = st_read;
							end
		st_renable  :  begin
									if((valid == 1'b1) && ~hwrite)
										next_state = st_read;
									else if((valid == 1'b1) && hwrite)
										next_state = st_wwait;
									else if(~valid)
										next_state = st_idle;
									else
										next_state = st_renable;
							end
		default: next_state = st_idle;
		endcase
end

//Temp Logic
always@(*)
begin
		case(state)
				st_idle:begin
							if(valid==1 && hwrite==0)
								begin
									paddr_temp = haddr;
									pwrite_temp = hwrite;
									psel_temp = tempselx;
									penable_temp = 0;
									hreadyout_temp = 0;
								end
							else if(valid==1 && hwrite==1)
								begin
									psel_temp=0;
									penable_temp=0;
									hreadyout_temp=1;
								end
							else
								begin
									psel_temp=0;
									penable_temp=0;
									hreadyout_temp=1;
								end
			          end
				
				st_read:
							begin
									penable_temp=1;
									hreadyout_temp=1;
							end
				
				st_renable:begin
									if(valid==1 && hwrite==0)
										begin
											paddr_temp = haddr;
											pwrite_temp = hwrite;
											psel_temp = tempselx;
											penable_temp = 0;
											hreadyout_temp = 0;
										end
									else if(valid==1 && hwrite==1)
										begin
											psel_temp=0;
											penable_temp=0;
											hreadyout_temp=1;
										end
									else
										begin
											psel_temp=0;
											penable_temp=0;
											hreadyout_temp=1;
										end
								end
				st_wwait:begin
								paddr_temp=haddr1;
								pwdata_temp=hwdata;
								pwrite_temp=hwrite;
								psel_temp=tempselx;
								penable_temp=0;
								hreadyout_temp=0;
							end
							
			   st_write:begin
								penable_temp=1;
								hreadyout_temp=1;
							end
				
				st_wenable:begin
								if(valid==1 && hwrite==0)
									begin
										hreadyout_temp=1;
										psel_temp=0;
										penable_temp=0;
									end
								else if(valid==1 && hwrite==0)
									begin
										paddr_temp=haddr1;
										pwrite_temp=hwritereg;
										psel_temp=tempselx;
										penable_temp=0;
										hreadyout_temp=0;
									end
								else	
									begin
										hreadyout_temp=1;
										psel_temp=0;
										penable_temp=0;
									end
							 end
							 
				st_writep:begin
								penable_temp=1;
								hreadyout_temp=1;
							end
				
	         st_wenablep:begin
								paddr_temp=haddr1;
								pwdata_temp=hwdata;
								pwrite_temp=hwrite;
								psel_temp=tempselx;
								penable_temp=0;
								hreadyout_temp=0;
							end
		endcase
end

//output logic
always@(posedge hclk)
		begin
				if(!hresetn)
					begin
					paddr<=0;
					pwdata<=0;
					pwrite<=0;
					psel<=0;
					penable<=0;
					hreadyout<=1;
					end
				else
					begin
					paddr<=paddr_temp;
					pwdata<=pwdata_temp;
					pwrite<=pwrite_temp;
					psel<=psel_temp;
					penable<=penable_temp;
					hreadyout<=hreadyout_temp;
					end
		end
endmodule		