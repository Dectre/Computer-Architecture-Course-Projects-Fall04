#include <stdint.h>

#define N 20

int32_t arr[N] = {
    12, -5, 33, 7, 0, 19, -12, 44, 8, -1,
    3, 27, 15, 2, -8, 6, 9, -3, 25, 1
};

int main() {
    for (int i = 0; i < N - 1; i++) {
        for (int j = 0; j < N - 1 - i; j++) {
            if (arr[j] > arr[j + 1]) {
                int32_t temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
    return 0;
}
