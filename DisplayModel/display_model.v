module display_model(
    input HCLK,
    input HRESETn,
    output reg DEC_DONE
);

parameter WIDTH = 240;
parameter HEIGHT = 320;
parameter BMP_HEADER_NUM = 54;
parameter FILESIZE = BMP_HEADER_NUM + (WIDTH * HEIGHT * 3);

reg [7:0] out_BMP [0:WIDTH*HEIGHT*3-1];
reg [7:0] BMP_header [0:BMP_HEADER_NUM-1];

integer fd, i;

initial begin
    // BMP 헤더 초기화
    for (i = 0; i < BMP_HEADER_NUM; i = i + 1)
        BMP_header[i] = 8'd0;

    // 필수 BMP 헤더 필드 설정
    BMP_header[0]  = "B";        
    BMP_header[1]  = "M";        
    BMP_header[2]  = FILESIZE % 256;         // Little Endian
    BMP_header[3]  = (FILESIZE >> 8) % 256;  
    BMP_header[4]  = (FILESIZE >> 16) % 256; 
    BMP_header[5]  = (FILESIZE >> 24) % 256; 
    BMP_header[10] = BMP_HEADER_NUM;         // 데이터 시작 위치

    BMP_header[14] = 40;                     // DIB 헤더 크기

    BMP_header[18] = WIDTH % 256;            // 너비
    BMP_header[19] = (WIDTH >> 8) % 256;

    BMP_header[22] = HEIGHT % 256;           // 높이
    BMP_header[23] = (HEIGHT >> 8) % 256;

    BMP_header[26] = 1;                      // 색상 평면 수
    BMP_header[28] = 24;                     // 비트 깊이 (24비트 RGB)

    BMP_header[34] = (WIDTH * HEIGHT * 3) % 256;    
    BMP_header[35] = ((WIDTH * HEIGHT * 3) >> 8) % 256;
    BMP_header[36] = ((WIDTH * HEIGHT * 3) >> 16) % 256;
    BMP_header[37] = ((WIDTH * HEIGHT * 3) >> 24) % 256;

    BMP_header[38] = 8'h13;  // 수평 해상도 (픽셀/미터)
    BMP_header[39] = 8'h0B;

    BMP_header[42] = 8'h13;  // 수직 해상도 (픽셀/미터)
    BMP_header[43] = 8'h0B;

    // 이미지 데이터 로딩
    $readmemh("../Image2Hex/image.hex", out_BMP);

    // BMP 파일 생성
    fd = $fopen("image_out.bmp", "wb+");

    for (i = 0; i < BMP_HEADER_NUM; i = i + 1)
        $fwrite(fd, "%c", BMP_header[i]);

    for (i = 0; i < WIDTH*HEIGHT*3; i = i + 1)
        $fwrite(fd, "%c", out_BMP[i]);

    DEC_DONE <= 1;
    $fclose(fd);
end

endmodule