module display_model_tb;

reg HCLK, HRESETn;
wire DEC_DONE;

// 인스턴스 생성
display_model dut (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .DEC_DONE(DEC_DONE)
);

// 클럭 신호 생성
initial begin
    HCLK = 0;
    HRESETn = 0;

    #25 HRESETn = 1;
end

// 클럭 생성
always #10 HCLK = ~HCLK;

// 테스트 완료 확인
always @(posedge HCLK) begin
    if (DEC_DONE) begin
        $display("Test complete: DEC_DONE asserted");
        $finish;
    end
end

endmodule