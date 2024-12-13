module fsm_image_sensor_tb;

    reg HCLK;
    reg HRESETn;

    // 출력 신호
    wire VSYNC, HSYNC;
    wire [7:0] DATA_R0, DATA_G0, DATA_B0;
    wire [7:0] DATA_R1, DATA_G1, DATA_B1;
    wire ctrl_done;

    // 테스트 대상 모듈 인스턴스화
    fsm_image_sensor dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .VSYNC(VSYNC),
        .HSYNC(HSYNC),
        .DATA_R0(DATA_R0),
        .DATA_G0(DATA_G0),
        .DATA_B0(DATA_B0),
        .DATA_R1(DATA_R1),
        .DATA_G1(DATA_G1),
        .DATA_B1(DATA_B1),
        .ctrl_done(ctrl_done)
    );

    // 클럭 신호 생성
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, fsm_image_sensor_tb);
    end

    initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK; // 50MHz 클럭 생성
    end

    // 리셋 신호 설정
    initial begin
        HRESETn = 0;
        #25 HRESETn = 1; // 리셋 비활성화
    end

    // 테스트 로그 출력
    always @(posedge HCLK) begin
        if (ctrl_done) begin
            $display("Test complete: ctrl_done asserted");
            $finish;
        end
        $monitor("Time: %0d, DATA_R0: %h, DATA_G0: %h, DATA_B0: %h, DATA_R1: %h, DATA_G1: %h, DATA_B1: %h",
            $time, DATA_R0, DATA_G0, DATA_B0, DATA_R1, DATA_G1, DATA_B1);
    end

endmodule