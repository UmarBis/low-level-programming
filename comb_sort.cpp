#include <iostream>
#include <vector>
using namespace std;


void comb_sort(vector<int>& arr) {
    int n = arr.size();
    int gap = n;
    bool swapped = true;

    while (gap > 1 || swapped) {
        // уменьшаем gap
        gap = (gap * 10) / 13;
        if (gap < 1) gap = 1;

        swapped = false;
        for (int i = 0; i + gap < n; ++i) {
            if (arr[i] > arr[i + gap]) {
                swap(arr[i], arr[i + gap]);
                swapped = true;
            }
        }
    }
}
int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;
    if (n < 1) return 0;
    if (n > 100) n = 100; // ограничение на размер

    vector<int> arr(n);
    for (int i = 0; i < n; i++) {
        cin >> arr[i];
    }

    comb_sort(arr);

    for (int i = 0; i < n; i++) {
        cout << arr[i] << (i + 1 == n ? '\n' : ' ');
    }

    return 0;
}
