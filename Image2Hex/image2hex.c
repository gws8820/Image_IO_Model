#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#pragma pack(push, 1)

typedef struct {
    uint16_t bfType;
    uint32_t bfSize;
    uint16_t bfReserved1;
    uint16_t bfReserved2;
    uint32_t bfOffBits;
} BMPFileHeader;

typedef struct {
    uint32_t biSize;
    int32_t biWidth;
    int32_t biHeight;
    uint16_t biPlanes;
    uint16_t biBitCount;
    uint32_t biCompression;
    uint32_t biSizeImage;
    int32_t biXPelsPerMeter;
    int32_t biYPelsPerMeter;
    uint32_t biClrUsed;
    uint32_t biClrImportant;
} BMPInfoHeader;

#pragma pack(pop)

int main() {
    FILE *image = fopen("image.bmp", "rb");
    if(!image) {
        printf("Error: Could not open image.bmp\n");
        return -1;
    }

    FILE *hex = fopen("image.hex", "w");
    if(!hex) {
        printf("Error: Could not open image.hex\n");
        fclose(image);
        return -1;
    }
    
    BMPFileHeader fileHeader;
    BMPInfoHeader infoHeader;
    
    fread(&fileHeader, sizeof(BMPFileHeader), 1, image);
    fread(&infoHeader, sizeof(BMPInfoHeader), 1, image);

    if (fileHeader.bfType != 0x4D42) {
        printf("Error: The file is not a valid BMP file.\n");
        fclose(image);
        fclose(hex);
        return -1;
    }

    if (infoHeader.biBitCount != 32) {
        printf("Error: This code only supports 32-bit BMP.\n");
        fclose(image);
        fclose(hex);
        return -1;
    }

    int width = infoHeader.biWidth;
    int height = infoHeader.biHeight;

    fseek(image, fileHeader.bfOffBits, SEEK_SET);

    uint8_t pixel[4];
    for (int i=0; i<height; i++) {
        for (int j=0; j<width; j++) {
            if (fread(pixel, sizeof(uint8_t), 4, image) != 4) { // Reads 4 bytes at a time
                printf("Error: Could not read pixel data.\n");
                fclose(image);
                fclose(hex);
                return -1;
            }

            /* Ignore Alpha Channel */
            fprintf(hex, "%02X\n", pixel[2]);
            fprintf(hex, "%02X\n", pixel[1]);
            fprintf(hex, "%02X\n", pixel[0]);
        }
    }

    fclose(image);
    fclose(hex);
    printf("Conversion completed. Check image.hex\n");
    return 0;
}
