module sensor_model #(
    parameter WIDTH = 240,
    parameter HEIGHT = 320,
    parameter INFILE = "../Image2Hex/image.hex"
)(
    input HCLK, HRESETn,
    input [1:0] nstate,
    output reg VSYNC, HSYNC,
    output reg [7:0] DATA_R0, DATA_G0, DATA_B0,
    output reg [7:0] DATA_R1, DATA_G1, DATA_B1,
    output reg ctrl_done,
    output reg [31:0] ctrl_vsync_cnt,
    output reg [31:0] ctrl_hsync_cnt,
    output reg [31:0] col
);

reg [31:0] row;
reg [7:0] total_memory [0:WIDTH*HEIGHT*3-1];
reg [7:0] org_R [0:WIDTH*HEIGHT-1];
reg [7:0] org_G [0:WIDTH*HEIGHT-1];
reg [7:0] org_B [0:WIDTH*HEIGHT-1];

// FSM 상태 정의
parameter ST_IDLE  = 2'b00;
parameter ST_VSYNC = 2'b01;
parameter ST_HSYNC = 2'b10;
parameter ST_DATA  = 2'b11;

// 메모리 초기화
initial begin
    $readmemh(INFILE, total_memory);
    for (integer i = 0; i < WIDTH * HEIGHT; i = i + 1) begin
        org_R[i] = total_memory[i * 3];
        org_G[i] = total_memory[i * 3 + 1];
        org_B[i] = total_memory[i * 3 + 2];
    end
end

// FSM 제어
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        // 초기화 코드
        VSYNC <= 0; HSYNC <= 0; ctrl_done <= 0;
        DATA_R0 <= 0; DATA_G0 <= 0; DATA_B0 <= 0;
        DATA_R1 <= 0; DATA_G1 <= 0; DATA_B1 <= 0;
        ctrl_vsync_cnt <= 0; ctrl_hsync_cnt <= 0;
        col <= 0; row <= 0;
    end else begin
        case (nstate)
            ST_VSYNC: begin
                VSYNC <= 1;
                HSYNC <= 0;
                ctrl_vsync_cnt <= ctrl_vsync_cnt + 1;
                ctrl_hsync_cnt <= 0;
            end

            ST_HSYNC: begin
                VSYNC <= 0;
                HSYNC <= 1;
                ctrl_hsync_cnt <= ctrl_hsync_cnt + 1;
                ctrl_vsync_cnt <= 0;
            end

            ST_DATA: begin
                VSYNC <= 0; // VSYNC 비활성화
                HSYNC <= 0;
                if (row < HEIGHT && col < WIDTH - 1) begin
                    // 픽셀 데이터 출력
                    DATA_R0 <= org_R[WIDTH * row + col];
                    DATA_G0 <= org_G[WIDTH * row + col];
                    DATA_B0 <= org_B[WIDTH * row + col];

                    DATA_R1 <= org_R[WIDTH * row + col + 1];
                    DATA_G1 <= org_G[WIDTH * row + col + 1];
                    DATA_B1 <= org_B[WIDTH * row + col + 1];

                    // 픽셀 인덱스 증가
                    col <= col + 2;

                    // 행 또는 전체 데이터 끝 검사
                    if (col + 2 >= WIDTH) begin
                        col <= 0;
                        row <= row + 1;
                    end

                    if (row + 1 >= HEIGHT && (col + 2) >= WIDTH) begin
                        ctrl_done <= 1;
                        row <= 0;
                        col <= 0;
                    end
                end else begin
                    ctrl_done <= 1;
                    row <= 0;
                    col <= 0;
                end
            end

            default: begin
                VSYNC <= 0; HSYNC <= 0;
                ctrl_vsync_cnt <= 0; ctrl_hsync_cnt <= 0;
                col <= 0; row <= 0;
                ctrl_done <= 0;
            end
        endcase
    end
end

endmodule