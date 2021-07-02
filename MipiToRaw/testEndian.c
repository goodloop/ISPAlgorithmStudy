#include <stdio.h>

int main(int argc, char * argv[])
{
    int a = 0x08040201;
    char* p = (char*)&a;
    printf("%c\n", p[0] + '0');
    printf("%c\n", p[1] + '0');
    printf("%c\n", p[2] + '0');
    printf("%c\n", p[3] + '0');
    return 0;
}
