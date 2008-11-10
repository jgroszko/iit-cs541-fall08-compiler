/* a simple driver for scheme_entry */
#include <stdio.h>
#include <stdlib.h>

#define vector_mask 0x7
#define vector_tag  0x2

#define pair_mask 0x7
#define pair_tag  0x1

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

#define word_size 8
#define heap_size word_size*32 // 32 words should be enough for anybody

void print_result(int val)
{
    if((val & vector_mask) == vector_tag)
    {
	int size = *(int*)(val-2);
	size = size >> fixnum_shift;

	printf("#(");

	if(size != 0)
	{
	    int element = *(int*)(val+2);
	    print_result(element);

	    int i;
	    for(i = 1; i < size; i++)
	    {
		element = *(int*)(val+(4*i)+2);

		printf(" . ");
		print_result(element);
	    }
	}

	printf(")");
    }
    else if((val & pair_mask) == pair_tag)
    {
	int first = *(int*)(val-1);
	int second = *(int*)(val+3);

	printf("(");
	print_result(first);
	printf(" . ");
	print_result(second);
	printf(")");
    }
    else if((val & fixnum_mask) == fixnum_tag)
    {
	printf("%d", val >> fixnum_shift);
    }
    else if((val & char_mask) == char_tag)
    {
	printf("#\\%c", val >> char_shift);
    }
    else if((val & bool_mask) == bool_tag)
    {
	printf( (val >> bool_shift) ? "#t" : "#f" );
    }
    else if(val == empty_list)
    {
	printf("()");
    }
}

int main(int argc, char ** argv)
{
    void* heap = malloc(heap_size);
    int val = scheme_entry(heap);
    print_result(val);
    printf("\n");

    free(heap);

    return 0;
}
