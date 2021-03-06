#include "string_itoa.h"

void reverse(char s[])
 {
     int i, j;
     char c;

     for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
         c = s[i];
         s[i] = s[j];
         s[j] = c;
     }
 }

int itoa(int num, unsigned char* str, int len, int base)
{
    int sum = num;
    int i = 0;
    int digit;
    if (len == 0)
        return -1;
    do
    {
        digit = sum % base;
        if (digit < 0xA)
            str[i++] = '0' + digit;
        else
            str[i++] = 'A' + digit - 0xA;
        sum /= base;
    }while (sum && (i < (len - 1)));
    if (i == (len - 1) && sum)
        return -1;
    str[i] = '\0';
    reverse(str);
    return 0;
}
