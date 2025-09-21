#include <stdio.h>

#define N 6

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

int main(void)
{
    // TODO: test with global array
    int unsorted_list[] = {12, 7, 40, 3, 9, -2};
    printf("\n[-] unsorted: ");
    printarray(unsorted_list);

    int *array = sort(unsorted_list);
    printf("[-] sorted:   ");
    printarray(array);

    printf("\nPress <enter> to restart...\n");
    char c;
    scanf(" %c", &c);

    return 0;
}