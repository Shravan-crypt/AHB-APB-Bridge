module apb_controller_tb();

    // 1. Declare inputs to the DUT as reg
    reg hclk;
    reg hresetn;
    reg valid;
    reg hwritereg;
    reg hwrite;
    reg [31:0] haddr;
    reg [31:0] haddr1;
    reg [31:0] haddr2;
    reg [31:0] hwdata;
    reg [31:0] hwdata1;
    reg [31:0] hwdata2;
    reg [31:0] prdata;
    reg [2:0] tempselx;

    // 2. Declare outputs from the DUT as wire
    wire pwrite;
    wire penable;
    wire [2:0] psel;
    wire hreadyout;
    wire [31:0] pwdata;
    wire [31:0] paddr;

    // 3. Instantiate the Device Under Test (DUT)
    apb_controller dut (
        .hclk(hclk),
        .hresetn(hresetn),
        .valid(valid),
        .hwritereg(hwritereg),
        .hwrite(hwrite),
        .haddr(haddr),
        .haddr1(haddr1),
        .haddr2(haddr2),
        .hwdata(hwdata),
        .hwdata1(hwdata1),
        .hwdata2(hwdata2),
        .prdata(prdata),
        .tempselx(tempselx),
        .pwrite(pwrite),
        .penable(penable),
        .psel(psel),
        .hreadyout(hreadyout),
        .pwdata(pwdata),
        .paddr(paddr)
    );

    // 4. Clock Generation (10ns period)
    always begin
        #5 hclk = ~hclk;
    end

    // 5. Test Stimulus
    initial begin
        // Initialize all inputs
        hclk       = 0;
        hresetn    = 0;
        valid      = 0;
        hwritereg  = 0;
        hwrite     = 0;
        haddr      = 32'h0;
        haddr1     = 32'h0;
        haddr2     = 32'h0;
        hwdata     = 32'h0;
        hwdata1    = 32'h0;
        hwdata2    = 32'h0;
        prdata     = 32'h0;
        tempselx   = 3'b000;

        // Reset sequence
        #20;
        hresetn = 1;
        #10;

        // Test 1: Write Transaction (IDLE -> WAIT -> WRITE -> WENABLE)
        valid     = 1;
        hwrite    = 1;
        haddr     = 32'h8000_1000;
        tempselx  = 3'b001;
        #10; 
        
        haddr1    = 32'h8000_1000; // Simulating pipeline stages
        hwdata    = 32'hAAAA_BBBB;
        valid     = 0;             // Single write, no back-to-back transfer
        #10;
        #10;
        #10;

        // Test 2: Read Transaction (IDLE -> READ -> RENABLE)
        valid     = 1;
        hwrite    = 0;
        haddr     = 32'h8400_2000;
        tempselx  = 3'b010;
        #10;
        
        valid     = 0;
        prdata    = 32'h1234_5678;
        #10;
        #10;

        // Test 3: Back-to-Back Write Transactions (Testing writep / wenablep states)
        valid     = 1;
        hwrite    = 1;
        haddr     = 32'h8800_3000;
        tempselx  = 3'b100;
        #10;

        haddr1    = 32'h8800_3000;
        hwdata    = 32'hCCCC_DDDD;
        hwritereg = 1;
        valid     = 1;             // Keep valid high for next address
        haddr     = 32'h8800_3004; 
        #10;
        #10;
        #10;

        valid     = 0;
        #40;
        
        $stop;
    end

endmodule