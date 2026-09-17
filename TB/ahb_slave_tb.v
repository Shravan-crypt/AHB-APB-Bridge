module ahb_slave_tb();

    // 1. Declare inputs to the DUT as reg
    reg hclk;
    reg hresetn;
    reg hwrite;
    reg hreadyin;
    reg [1:0] htrans;
    reg [31:0] haddr;
    reg [31:0] hwdata;
    reg [31:0] prdata;

    // 2. Declare outputs from the DUT as wire
    wire [1:0] hresp;
    wire [31:0] hrdata;
    wire [31:0] haddr1;
    wire [31:0] haddr2;
    wire [31:0] hwdata1;
    wire [31:0] hwdata2;
    wire [2:0] tempselx;
    wire valid;
    wire hwritereg;
    wire hwritereg1;

    // 3. Instantiate the Device Under Test (DUT)
    ahb_slave dut (
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .htrans(htrans),
        .haddr(haddr),
        .hwdata(hwdata),
        .prdata(prdata),
        .hresp(hresp),
        .hrdata(hrdata),
        .valid(valid),
        .haddr1(haddr1),
        .haddr2(haddr2),
        .hwdata1(hwdata1),
        .hwdata2(hwdata2),
        .hwritereg(hwritereg),
        .hwritereg1(hwritereg1),
        .tempselx(tempselx)
    );

    // 4. Clock Generation (10ns period)
    always begin
        #5 hclk = ~hclk;
    end

    // 5. Test Stimulus
    initial begin
        // Initialize all inputs
        hclk    = 0;
        hresetn = 0;
        hwrite  = 0;
        hreadyin = 0;
        htrans  = 2'b00; 
        haddr   = 32'h0;
        hwdata  = 32'h0;
        prdata  = 32'h0;

        // Reset sequence
        #20;
        hresetn = 1; 
        #10;

        // Test 1: Peripheral 1 Address Range
        haddr    = 32'h8000_1000; 
        hreadyin = 1;
        htrans   = 2'b10;         
        hwrite   = 1;
        hwdata   = 32'hA5A5_A5A5;
        #10; 

        // Test 2: Peripheral 2 Address Range
        haddr    = 32'h8400_5000; 
        hwdata   = 32'h5A5A_5A5A;
        #10;

        // Test 3: Peripheral 3 Address Range
        haddr    = 32'h8800_F000; 
        hwdata   = 32'h1111_2222;
        #10;

        // Test 4: Invalid Address and Ready Low
        haddr    = 32'h9000_0000; 
        hreadyin = 0;             
        htrans   = 2'b00;         
        #10;

        // Test 5: Verify Read Data Loopback
        prdata = 32'hDEAD_BEEF;
        #10;

        // Let remaining values propagate through pipelines
        #30;

        $stop; 
    end

endmodule