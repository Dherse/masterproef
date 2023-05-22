#include <stdio.h>
#include <string.h>

void main() {
    char buffer[88];
    for(int i = 0; i <= 100; i++) {
        int len = sprintf(
            buffer,
            "%s%s",
            i % 3 ? "" : "Fizz",
            i % 5 ? "" : "Buzz");
        if (len == 0)
            sprintf(buffer, "%d", i);
        printf("%s\n", buffer);
    }
}