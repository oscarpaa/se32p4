#include "sestdio.h"

#define N 6

int unsorted_list[] = {12, 7, 40, 3, 9, -2};

void printarray(int *array)
{
    seprintf("[");
    for (int i = 0; i < N - 1; i++)
    {
        seprintf("%d, ", *(array + i));
    }
    seprintf("%d]\n", *(array + N - 1));
}

int *sort(int *array)
{
    int bubble;
    for (int j = 0; j < N - 1; j++)
    {
        for (int i = 0; i < N - 1; i++)
        {
            bubble = *(array + i);
            if (*(array + i + 1) < bubble)
            {
                *(array + i) = *(array + i + 1);
                *(array + i + 1) = bubble;
            }
        }
    }
    return array;
}

int main(void)
{
    seprintf("\n[-] unsorted: ");
    printarray(unsorted_list);

    int *array = sort(unsorted_list);
    seprintf("[-] sorted:   ");
    printarray(array);

    return 0;
}