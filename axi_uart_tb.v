
`timescale 1ns / 1ps

module axi_uart_tb();

    reg             s_axi_aclk      ;
    reg             s_axi_aresetn   ;
    wire            interrupt       ;
    reg     [3:0]   s_axi_awaddr    ;
    reg             s_axi_awvalid   ;
    wire            s_axi_awready   ;
    reg     [31:0]  s_axi_wdata     ;
    reg     [3:0]   s_axi_wstrb     ;
    reg             s_axi_wvalid    ;
    wire            s_axi_wready    ;
    wire    [1:0]   s_axi_bresp     ;
    wire            s_axi_bvalid    ;
    reg             s_axi_bready    ;
    reg     [3:0]   s_axi_araddr    ;
    reg             s_axi_arvalid   ;
    wire            s_axi_arready   ;
    wire    [31:0]  s_axi_rdata     ;
    wire    [1:0]   s_axi_rresp     ;
    wire            s_axi_rvalid    ;
    reg             s_axi_rready    ;
    reg             rx;
    wire            tx;

    parameter       Clockperiod = 20;     // 20ns --> Freq = 50MHz

    reg             test_bagin      ;
    reg     [1:0]   test_num        ;

    reg	            test_finish     ;

    parameter [1:0] Test_Cycle = 2'd1   ;


    axi_uartlite_0 uart_ip (
        .s_axi_aclk     (s_axi_aclk)    , 
        .s_axi_aresetn  (s_axi_aresetn) ,
        .interrupt      (interrupt)     ,
        .s_axi_awaddr   (s_axi_awaddr)  ,
        .s_axi_awvalid  (s_axi_awvalid) ,
        .s_axi_awready  (s_axi_awready) ,
        .s_axi_wdata    (s_axi_wdata)   ,
        .s_axi_wstrb    (s_axi_wstrb)   ,
        .s_axi_wvalid   (s_axi_wvalid)  ,
        .s_axi_wready   (s_axi_wready)  ,
        .s_axi_bresp    (s_axi_bresp)   ,
        .s_axi_bvalid   (s_axi_bvalid)  ,
        .s_axi_bready   (s_axi_bready)  ,
        .s_axi_araddr   (s_axi_araddr)  ,
        .s_axi_arvalid  (s_axi_arvalid) ,
        .s_axi_arready  (s_axi_arready) ,
        .s_axi_rdata    (s_axi_rdata)   ,
        .s_axi_rresp    (s_axi_rresp)   ,
        .s_axi_rvalid   (s_axi_rvalid)  ,
        .s_axi_rready   (s_axi_rready)  , 
        .rx             (rx)            ,
        .tx             (tx)              
    );

//  IP Initialization
    glbl glbl();


//  ============================= Control =============================
//  50MHz Clock
    initial                 s_axi_aclk = 1'b0       ;
    always #(Clockperiod/2) s_axi_aclk = ~s_axi_aclk;
    

    initial begin
        s_axi_aresetn   =   1'b0    ;

        s_axi_awaddr    =   4'h0    ;
        s_axi_awvalid   =   1'b0    ;
        s_axi_wdata     =   32'h0   ;
        s_axi_wvalid    =   1'b0    ;
        s_axi_wstrb     =   4'h0    ;
        s_axi_bready    =   1'b0    ;
        s_axi_araddr    =   4'h0    ;
        s_axi_arvalid   =   1'b0    ;
        s_axi_rready    =   1'b0    ;

        test_bagin      =   1'b0    ;
        test_num        =   2'd0    ;
        test_finish     =   1'b0    ;

        #1500
        s_axi_aresetn   =   1'b1    ;
        s_axi_bready    =   1'b1    ;

        test_bagin      =   1'b1    ;

    end

//  Test Writing
    always @ (posedge s_axi_aclk) begin
        if (test_bagin && test_num<Test_Cycle) begin
        //  Config
            s_axi_awaddr    =   4'hc    ;
            s_axi_awvalid   =   1'b1    ;
            s_axi_wdata     =   32'h13  ;
            s_axi_wstrb     =   4'h2    ;
            s_axi_wvalid    =   1'b1    ;
            //wait (s_axi_awvalid && s_axi_awready);
            //@ (posedge s_axi_aclk);
            wait (s_axi_wvalid && s_axi_wready);
            @ (posedge s_axi_aclk);
            s_axi_awvalid   =   1'b0    ;
            s_axi_wvalid    =   1'b0    ;
            wait (s_axi_bvalid);
            @ (posedge s_axi_aclk);
        //  Write a test data
            s_axi_awaddr    =   4'h4    ;
            s_axi_awvalid   =   1'b1    ;
            s_axi_wdata     =   32'haa  ;
            s_axi_wstrb     =   4'h0    ;
            s_axi_wvalid    =   1'b1    ;
            //wait (s_axi_awvalid && s_axi_awready);
            //@ (posedge s_axi_aclk);
            wait (s_axi_wvalid && s_axi_wready);
            @ (posedge s_axi_aclk);
            s_axi_awvalid   =   1'b0    ;
            s_axi_wvalid    =   1'b0    ;
            wait (s_axi_bvalid);
            @ (posedge s_axi_aclk);
            $display ("Test finished!");
            test_num        =   test_num + 2'd1 ;
        //  Wait for the IP-finish
            wait (interrupt);
            @ (posedge s_axi_aclk);
            $display("%s%t", "TX writing just finished!", $time);
        end
        else if (test_num>=Test_Cycle) begin
            test_finish     =   1'b1;
        end
    end

endmodule