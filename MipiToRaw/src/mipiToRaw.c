/*******************************************************************************
 *  All rights reserved, Copyright (C) wtzhu
 * -----------------------------------------------------------------------------
 * [File Name]: 			main.cpp
 * [Description]: 			Main file of mipiToRaw
 *
 * [Author]: 				Fred
 * [Date Of Creation]:      2021/0701
 * [e-mail]:                wtzhu_13@163.com
 * [Note]:
 *
 * ------------------------------------------------------------------------------
 * Date					Author				Modifications
 * ------------------------------------------------------------------------------
 * 2021-07				Fred                Created
 *******************************************************************************/
#include <stdio.h>

int main(int argc, char *argv[])
{
    short orgRaw10BitsArr[4] = {0x0155, 0x00f2, 0x0111, 0x0348};
    FILE *fOrgRaw = fopen("org.dat", "wb+");
    FILE *fMipiRaw = fopen("mipiRaw.dat", "wb");
    FILE *fOutRaw = fopen("out.dat", "wb+");

    // raw to mipi
    // 1.get the high 8-bit data and set to a new byte
    // 2.get the low 2-bit data and set to the individual byte, note the pos of the 2-bit
    char mipiRawArr[5] = {0};
    
    for(int i=0; i<4; i++)
    {
        mipiRawArr[i] = (char)(orgRaw10BitsArr[i] >> 2);
        mipiRawArr[4] = mipiRawArr[4] | ((((char)orgRaw10BitsArr[i]) & 0x03)<< (2*i));
    }

    // mipi to raw
    // 1. transform 8-bit to 16-bit and two shift to the left leave room for the low 2-bit
    // 2. get the low 2-bit
    // 3. combine the high 8-bit and the low 2-bit into one which is 10bits
    short outRawArr[4] = {0};
    for(int i=0; i<4; i++)
    {
        outRawArr[i] = ((outRawArr[i] | (short)mipiRawArr[i]) << 2) &0x3FF | ((mipiRawArr[4] >> (i*2)) & 0x03);
    }

    // save as .dat file
    fwrite(mipiRawArr, 1, 5, fMipiRaw);
    fwrite(outRawArr, 1, 8, fOutRaw);
    fwrite(orgRaw10BitsArr, 1, 8, fOrgRaw);
    
    fclose(fMipiRaw);
    fclose(fOutRaw);
    fclose(fOrgRaw);
    return 0;
}