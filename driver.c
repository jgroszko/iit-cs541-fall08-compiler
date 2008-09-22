/* a simple driver for scheme_entry */
#include <stdio.h>

#define fixnum_mask  0x3
#define fixnum_tag   0x0
#define fixnum_shift 2

#define char_mask   0xFF
#define char_tag    0x0F
#define char_shift  8

#define bool_mask   0x7F
#define bool_tag    0x1F
#define bool_shift  7

#define empty_list   0x2F

int main(int argc, char ** argv)
{
    int val = scheme_entry();
    if((val & fixnum_mask) == fixnum_tag)
    {
	printf("%d\n", val >> fixnum_shift);
    }
    else if((val & char_mask) == char_tag)
    {
	printf("%c\n", val >> char_shift);
    }
    else if((val & bool_mask) == bool_tag)
    {
	printf("%i\n", val >> bool_shift);
    }
    else if(val == empty_list)
    {
	printf("()\n");
    }
    return 0;
}
