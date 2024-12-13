module fsm_controller #(
    parameter START_UP_DELAY = 100,
    parameter HSYNC_DELAY = 160,
    parameter WIDTH = 240
)(
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] ctrl_vsync_cnt,
    input wire [31:0] ctrl_hsync_cnt,
    input wire [31:0] col,
    input wire ctrl_done,
    output reg [1:0] nstate
);

reg [1:0] cstate;

// FSM 상태 정의
parameter ST_IDLE  = 2'b00;
parameter ST_VSYNC = 2'b01;
parameter ST_HSYNC = 2'b10;
parameter ST_DATA  = 2'b11;

// 상태 갱신
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        cstate <= ST_IDLE;
    else
        cstate <= nstate;
end

// 상태 결정 로직
always @(*) begin
    case (cstate)
        ST_IDLE:
            nstate = ST_VSYNC;
        
        ST_VSYNC: begin
            if (ctrl_vsync_cnt >= START_UP_DELAY)
                nstate = ST_HSYNC;
            else
                nstate = ST_VSYNC;
        end

        ST_HSYNC: begin
            if (ctrl_hsync_cnt >= HSYNC_DELAY)
                nstate = ST_DATA;
            else
                nstate = ST_HSYNC;
        end

        ST_DATA: begin
            if (ctrl_done)
                nstate = ST_IDLE;
            else if (col == WIDTH - 2)
                nstate = ST_HSYNC;
            else
                nstate = ST_DATA;
        end

        default: nstate = ST_IDLE;
    endcase
end

endmodule