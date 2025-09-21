#include <stdio.h>

#define N 5

typedef signed short s8;

s8 unsorted_list[N] = {-1, 7, 40, 3, 9};

void printarray(s8 *array)
{
    printf("[");
    for (s8 i = 0; i < N - 1; i++)
    {
        printf("%d, ", *(array + i));
    }
    printf("%d]\n", *(array + N - 1));
}

s8 *sort(s8 *array)
{
    s8 bubble;
    for (s8 j = 0; j < N - 1; j++)
    {
        for (s8 i = 0; i < N - 1; i++)
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

int main()
{
    printarray(unsorted_list);

    s8 *array = sort(unsorted_list);
    printarray(array);

    return 0;
}