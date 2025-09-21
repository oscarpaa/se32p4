
#include <io.h>
#include <stdio.h>

#define N 5

int unsorted_list[N] = {12, 7, 40, 3, 9};

void printarray(int *array)
{
    printf("[");
    for (int i = 0; i < N - 1; i++)
    {
        printf("%d, ", *(array + i));
    }
    printf("%d]\n", *(array + N - 1));
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

int main()
{
    printarray(unsorted_list);
    int *array = sort(unsorted_list);
    printarray(array);

    while(1)
    {
        char  buffer[64];
        memset(buffer,0,sizeof(buffer));
        gets(buffer,sizeof(buffer));
    }

    return 0;
}