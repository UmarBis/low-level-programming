#include <stdio.h>

#define MAXN 100
int arr[MAXN]; 

int main(void) {
    int n;     
    int i;     
    int gap;   
    int swapped;
    int a, b;   

    // === читаем n ===
    scanf("%d", &n);
    if (n < 1) return 0;
    if (n > MAXN) n = MAXN;

    // === читаем массив ===
    i = 0;
read_loop:
    if (i >= n) goto read_done;       
    scanf("%d", &arr[i]);
    i = i + 1;
    goto read_loop;                   
read_done:

    // === инициализация comb sort ===
    gap = n;
    swapped = 1;

comb_outer:
    // уменьшаем gap
    gap = (gap * 10) / 13;
    if (gap < 1) gap = 1;

    swapped = 0;
    i = 0;

loop_i:
    if (!(i + gap < n)) goto after_loop_i; // если i+gap >= n ? выходим

    a = arr[i];
    b = arr[i + gap];
    if (!(a > b)) goto no_swap;  // если a <= b ? не меняем

    // обмен arr[i] и arr[i+gap]
    arr[i] = b;
    arr[i + gap] = a;
    swapped = 1;

no_swap:
    i = i + 1;
    goto loop_i; // повторить

after_loop_i:
    if (gap > 1) goto comb_outer; // если gap > 1 ? ещё раз
    if (swapped) goto comb_outer; // если были перестановки ? ещё раз

    // === вывод массива ===
    i = 0;
print_loop:
    if (i >= n) goto print_done;
    if (i + 1 == n) {
        printf("%d\n", arr[i]);
    }
    else {
        printf("%d ", arr[i]);
    }
    i = i + 1;
    goto print_loop;
print_done:

    return 0;
}
