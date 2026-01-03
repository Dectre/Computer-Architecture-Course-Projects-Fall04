#include <stdio.h>

int main() {
    int array[10] = {5, 12, -1, 16, -2, 3, 8, 0, 9, 20};

    int min_val = array[0];

    for (int i = 1; i < 10; i++) {
        int current_val = array[i];

        if (current_val < min_val) {
            min_val = current_val;
        }
    }

    printf("The minimum value is: %d\n", min_val);

    return 0;
}