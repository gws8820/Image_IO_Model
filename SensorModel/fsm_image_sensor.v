module fsm_image_sensor (
    input HCLK, HRESETn,
    output VSYNC, HSYNC,
    output [7:0] DATA_R0, DATA_G0, DATA_B0,
    output [7:0] DATA_R1, DATA_G1, DATA_B1,
    output ctrl_done
);

// 내부 신호 선언
wire [1:0] nstate;
wire [31:0] ctrl_vsync_cnt, ctrl_hsync_cnt, col;
wire local_done;

// FSM 컨트롤러 인스턴스
fsm_controller fsm_ctrl (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .ctrl_vsync_cnt(ctrl_vsync_cnt),
    .ctrl_hsync_cnt(ctrl_hsync_cnt),
    .col(col),
    .ctrl_done(local_done),
    .nstate(nstate)
);

// 센서 모델 인스턴스
sensor_model sensor_mod (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .nstate(nstate),
    .VSYNC(VSYNC),
    .HSYNC(HSYNC),
    .DATA_R0(DATA_R0),
    .DATA_G0(DATA_G0),
    .DATA_B0(DATA_B0),
    .DATA_R1(DATA_R1),
    .DATA_G1(DATA_G1),
    .DATA_B1(DATA_B1),
    .ctrl_done(local_done),
    .ctrl_vsync_cnt(ctrl_vsync_cnt),
    .ctrl_hsync_cnt(ctrl_hsync_cnt),
    .col(col)
);

endmodule